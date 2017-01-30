#!/bin/bash

. ./job_settings.sh

# inclement batch #
sed -ie "/BATCH_N=${BATCH_N}/d" job_settings.sh
echo "BATCH_N=$(( BATCH_N + 1 ))" >> job_settings.sh

cat ${ALL_FOFN} fofns*/* | sort | uniq -u > remain.fofn
L=$( cat remain.fofn | wc -l )
N=$(( (L + MAX_CHUNK - 1) / MAX_CHUNK ))
echo "remaining $L .bax.h5 files => require at least $N rounds"

## split the fofn
i="1"
while [ $i -lt $(( N + 1 )) ]; do
  echo "$(( 1+(i-1)*MAX_CHUNK )),$(( i * MAX_CHUNK ))p"
  cat remain.fofn | sed -ne "$(( 1+(i-1)*MAX_CHUNK )),$(( i * MAX_CHUNK ))p" > input_${i}of${N}.fofn
  i=$(( i + 1 ))
done

TC=$( cat input_1of${N}.fofn | wc -l )

## run the smrt pipe
if [[ -e input_1of${N}.fofn && $( cat input_1of${N}.fofn | wc -l ) -gt 0 ]]; then
  echo "Running SMRT Pipe with input_1of${N}.fofn / ${TC} .bax.h5 files"
  nohup ./run_SMRT_Analysis.sh input_1of${N}.fofn >& nohup_smrtpipe.log &
  nohup ./mvGoodAln_rename.sh ${TC} ${BATCH_N} >& nohup_mvGoodAln.log &
else 
  echo "Invalid fofn file."
fi
