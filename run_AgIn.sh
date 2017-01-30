#!/bin/bash

MODDIR=/hpgwork/hacone/P6_7515/Mods
AGINDIR=/work/hacone/AgIn_mercurial/Agin/target
BETA=/work/hacone/AgIn_mercurial/Agin/resources/P6C4.dat
REF=/work/hacone/Reference/hg38_7515_SVs/sequence/hg38_7515_SVs.fasta

RESULTDIR=/hpgwork/hacone/P6_7515/AgInResult
mkdir -p ${AgInResult}

# -b = P5C3 or LDAVector (Default)
# -g = -1.80 (~P4/C2) or -2.52 (P5/C3) <- 0.80!!
# -g = -0.55 (P6/C4) 

# predict methylation class

#ls -S Mods/ > .tmp

while read file; do

JVM_OPTS="-Xmx128G" ${AGINDIR}/dist/bin/launch \
-i ${MODDIR}/${file} \
-f ${REF} \
-o ${RESULTDIR}/${file%%.csv} \
-g -0.55 -l 40 -c -b ${BETA} predict

done < .tmp
