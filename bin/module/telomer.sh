#!/usr/bin/env bash

filename=$1			# input fasta file
pattern_file=$2			# pattern file for scan_for_matches
out=$3			# dir where to store output from scan_for_matches
aux=$4
in=$5

cat $filename | parallel --tmpdir $HOME/tmp --block 100M -k --pipe -L 2 "scan_for_matches $pattern_file - " > $out/telomer.fa

cat $out/telomer.fa  | paste - - | grep -w "A CCCTAA" | tr -d ' '| tr '\t' '\n' | cut -d':' -f-7 | tr '>' '@' | paste - -|awk '{print $1,$NF}'| LC_ALL=C sort --parallel=8 --temporary-directory=$HOME/tmp -k1,1 > $aux/A_ID_genomic 
cat $out/telomer.fa  | paste - - | grep -w "AA CCCTAA" | tr -d ' '| tr '\t' '\n' | cut -d':' -f-7 | tr '>' '@' | paste - -|awk '{print $1,$NF}'| LC_ALL=C sort --parallel=8 --temporary-directory=$HOME/tmp -k1,1 > $aux/AA_ID_genomic 
cat $out/telomer.fa  | paste - - | grep -w "TAA CCCTAA" | tr -d ' '| tr '\t' '\n' | cut -d':' -f-7 | tr '>' '@' | paste - -|awk '{print $1,$NF}'| LC_ALL=C sort --parallel=8 --temporary-directory=$HOME/tmp -k1,1 > $aux/TAA_ID_genomic 
cat $out/telomer.fa  | paste - - | grep -w "CTAA CCCTAA" | tr -d ' '| tr '\t' '\n' | cut -d':' -f-7 | tr '>' '@' | paste - -|awk '{print $1,$NF}'| LC_ALL=C sort --parallel=8 --temporary-directory=$HOME/tmp -k1,1 > $aux/CTAA_ID_genomic 
cat $out/telomer.fa  | paste - - | grep -w "CCTAA CCCTAA" | tr -d ' '| tr '\t' '\n' | cut -d':' -f-7 | tr '>' '@' | paste - -|awk '{print $1,$NF}'| LC_ALL=C sort --parallel=8 --temporary-directory=$HOME/tmp -k1,1 > $aux/CCTAA_ID_genomic 
cat $out/telomer.fa  | paste - - | grep -w "CCCTAA CCCTAA" | tr -d ' '| tr '\t' '\n' | cut -d':' -f-7 | tr '>' '@' | paste - -|awk '{print $1,$NF}'| LC_ALL=C sort --parallel=8 --temporary-directory=$HOME/tmp -k1,1 > $aux/CCCTAA_ID_genomic 

cat $in/processed.fq | paste - - - - | LC_ALL=C sort --parallel=8 --temporary-directory=$HOME/tmp -k1,1 > $in/processed_1line.fq

LC_ALL=C join $aux/A_ID_genomic $in/processed_1line.fq | tr " " "\n" | grep -v "1:[YN]:0:" | paste - - - - -| awk '{print $1,$3,$4,$5}' | tr " " "\n" > $out/A.fq
LC_ALL=C join $aux/AA_ID_genomic $in/processed_1line.fq | tr " " "\n" | grep -v "1:[YN]:0:" | paste - - - - -| awk '{print $1,$3,$4,$5}' | tr " " "\n" > $out/AA.fq
LC_ALL=C join $aux/TAA_ID_genomic $in/processed_1line.fq | tr " " "\n" | grep -v "1:[YN]:0:" | paste - - - - -| awk '{print $1,$3,$4,$5}' | tr " " "\n" > $out/TAA.fq
LC_ALL=C join $aux/CTAA_ID_genomic $in/processed_1line.fq | tr " " "\n" | grep -v "1:[YN]:0:" | paste - - - - -| awk '{print $1,$3,$4,$5}' | tr " " "\n" > $out/CTAA.fq
LC_ALL=C join $aux/CCTAA_ID_genomic $in/processed_1line.fq | tr " " "\n" | grep -v "1:[YN]:0:" | paste - - - - -| awk '{print $1,$3,$4,$5}' | tr " " "\n" > $out/CCTAA.fq
LC_ALL=C join $aux/CCCTAA_ID_genomic $in/processed_1line.fq | tr " " "\n" | grep -v "1:[YN]:0:" | paste - - - - -| awk '{print $1,$3,$4,$5}' | tr " " "\n" > $out/CCCTAA.fq
