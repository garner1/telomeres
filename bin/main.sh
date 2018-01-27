#!/usr/bin/env bash

# THIS SCRIPT CAN BE CALLED AS
# ./bliss.sh rm35 hg19 patfile quality

################################################################################

# clear
# DEFINING VARIABLES
experiment=$1			# e.i. rm31,32,34,35,50,51,53 corresponding to *$experiment*R{1,2}.fastq.gz
refgenome=$2			# full path to ref genome
patfile=$3			# is the pattern file
fastqDir=$4			# full path to directory with fastq file
numbproc=32

################################################################################

# PREPARE DIRECTORY STRUCTURE
datadir=$HOME/Work/dataset/telo && mkdir -p $datadir/$experiment
bin=$HOME/Dropbox/pipelines/BLISS/bin
in=$datadir/$experiment/indata && mkdir -p $in
out=$datadir/$experiment/outdata && mkdir -p $out
aux=$datadir/$experiment/auxdata && mkdir -p $aux

################################################################################

find $fastqDir -maxdepth 1 -type f -iname "*$experiment*.fastq.gz" | sort > filelist_"$experiment"

numb_of_files=`cat filelist_"$experiment" | wc -l`
r1=`cat filelist_"$experiment" | head -n1`
echo "R1 is " $r1
if [ $numb_of_files == 2 ]; then
    r2=`cat filelist_"$experiment" | tail -n1`
    echo "R2 is " $r2
fi
rm filelist_"$experiment"

################################################################################

# "$bin"/module/prepare_files.sh  $r1 $in $numb_of_files $r2
"$bin"/module/pattern_filtering.sh $in $out $patfile
"$bin"/module/prepare_for_mapping.sh $numb_of_files $out $aux $in

r1=$aux/r1.2b.aln.fq
umi_tools extract --stdin="$r1" --bc-pattern=NNNNNNNNXXXXXXXX --log=processed.log --stdout "$in"/processed.fastq.gz # Ns represent the random part of the barcode and Xs the fixed part (the barcode)

zcat "$in"/processed.fastq.gz | paste - - - -|awk '{print $1,substr($2,9,1000),$3,substr($4,9,1000)}'|tr ' ' '\n' > $in/processed.fq # remove the barcode
cat $in/processed.fq | paste - - - - | cut -f 1,2 | sed 's/^@/>/' | tr "\t" "\n" > $in/processed.fa # create fasta file from processed fastq
$bin/module/telomer.sh $in/processed.fa ../patterns/telomer $out $aux $in # prepare telomeric fastq files to be grouped by umi_tools

for fastq in $(ls $out/*.fq); do
    name=`echo $fastq | rev | cut -d'/' -f1 | rev | cut -d'.' -f1`
    bwa mem -t $numbproc $refgenome $fastq > $out/"$name".sam
    samtools view -H $out/$name.sam > $aux/header
    samtools view $out/$name.sam | awk '{OFS="\t";$2="16";$3="1";$4="1000";$5="255";$6="63M";$10="*";$11="*";print $0}' > $aux/tailer
    cat $aux/header $aux/tailer > $out/$name.sam
    samtools view -bS $out/$name.sam > $out/$name.bam
    samtools sort -o $out/$name.sorted.bam $out/$name.bam
    samtools index $out/$name.sorted.bam $out/$name.sorted.bam.bai
done

parallel "umi_tools dedup -I $out/{} -S $out/{.}.dedup.bam -L $out/{.}.group.log --edit-distance-threshold 2" ::: A.sorted.bam AA.sorted.bam TAA.sorted.bam CTAA.sorted.bam CCTAA.sorted.bam CCCTAA.sorted.bam

parallel "echo {};cat {}|grep 'Input Reads' " ::: $(ls $out/*.sorted.group.log) | paste - - > $out/summary.txt
echo >> $out/summary.txt
parallel "echo {};cat {}|grep 'Number of reads out' " ::: $(ls $out/*.sorted.group.log) | paste - - >> $out/summary.txt
