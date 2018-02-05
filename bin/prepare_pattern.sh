#!/bin/usr/env bash

exp=$1

cd ~/Work/pipelines/telomeres/patterns 

parallel "cat {} | awk '{print \$1,\$2,\$3,\"( A | ( AA | (TAA | (CTAA | (CCTAA | CCCTAA))))) CCCTAA\",\$4,\$5}' > telo_{}" ::: *$exp*

cd ~/Work/pipelines/telomeres/bin

