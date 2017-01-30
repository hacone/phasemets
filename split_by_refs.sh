#!/bin/bash

SETUP=/bio/package/pacbio/smrtanalysis/current/etc/setup.sh

rm .split.dat
for sd in $( ls . | grep succeed_.* ); do
  ls ${sd} | gawk '{ print "'$(pwd)/${sd}'/"$0 }' >> .split.dat
done

JOBD=$(pwd)/job_scripts
CBRD=$(pwd)/cmp_by_ref

mkdir -p $JOBD
mkdir -p $CBRD

Count=1
while read line; do
  Count=$(( $Count + 1 ))

  Movie=$( basename $line ); Movie=${Movie%%.cmp.h5}
  echo $Movie

  CMPPATH=${CBRD}/Movie/${Movie}
  mkdir -p ${CMPPATH}

  mv ${line} ${CMPPATH}/${Movie}.cmp.h5

  echo "#!/bin/bash" > ${JOBD}/gbr${Count}.sh
  echo "source ${SETUP}" >> ${JOBD}/gbr${Count}.sh
  echo "cd ${CBRD}/Movie/${Movie}/" >> ${JOBD}/gbr${Count}.sh
  echo "cmph5tools.py select --groupBy Reference ${CMPPATH}/${Movie}.cmp.h5" >> ${JOBD}/gbr${Count}.sh
  echo "echo \"done\"" >> ${JOBD}/gbr${Count}.sh

  qsub -q all.q -S /bin/bash \
  -o ${JOBD}/gbr${Count}.out -e ${JOBD}/gbr${Count}.err ${JOBD}/gbr${Count}.sh

done < .split.dat
