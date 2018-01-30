#!/usr/bin/env bash

r1=$1
r2=$2
in=$3

echo "Decompress fastq.gz ..."
gunzip -c $r1 > $in/r1-unzip
cat $in/r1-unzip | paste - - - - | cut -f 1,2 | sed 's/^@/>/' | tr "\t" "\n" > $in/r1.fa & pid1=$!
cat $in/r1-unzip | paste - - - - | LC_ALL=C sort --parallel=8 --temporary-directory=$HOME/tmp -k1,1 > $in/r1oneline.fq & pid2=$!
wait $pid1
cat  $in/r1.fa | paste - - > $in/r1oneline.fa & pid3=$!
wait $pid2
wait $pid3
echo 'Done'
