#!/bin/bash

#REF=/work/hacone/Reference/hg38/sequence/hg38.fasta
REF=/work/hacone/Reference/hg38_7515_SVs/sequence/hg38_7515_SVs.fasta

#find $(pwd)/cmp_by_ref/Merged/*.cmp.h5 > cmp_list.dat

mkdir -p $( pwd )/Mods
ResultDir=$( pwd )/Mods

cnt=0
while read file; do
  refname=$( basename $file ); refname=${refname%.cmp.h5}
  JOBSH=$(pwd)/job_scripts/cm_${refname}
  CMP=$file
  cnt=$(( ( $cnt % 20 ) + 1 ))
  hn=$(printf "b%02d" ${cnt})

cat <<EOL > ${JOBSH}.sh
#!/bin/bash
SEYMOUR_HOME=/bio/package/pacbio/smrtanalysis/current
source \$SEYMOUR_HOME/etc/setup.sh

ipdSummary.py -v \
--ipdModel \${SEYMOUR_HOME}/analysis/etc/algorithm_parameters/2015-11/kineticsTools/P6-C4.h5 \
--numWorkers 8 \
--csv ${ResultDir}/${refname}.csv \
--reference ${REF} \
${CMP} || exit \$?

echo "Finished on \$(date -u) with exit code \$?."
EOL

qsub -q all.q -S /bin/bash -o ${JOBSH}.out -e ${JOBSH}.err -l "hostname=${hn}" ${JOBSH}.sh 

echo ${hn}

done < cmp_list.dat

# --ipdModel \${SEYMOUR_HOME}/analysis/etc/algorithm_parameters/2014-09/kineticsTools/P6-C4.h5 \
# --ipdModel \${SEYMOUR_HOME}/analysis/etc/algorithm_parameters/2015-11/kineticsTools/P6-C4.h5 \
# --ipdModel \${SEYMOUR_HOME}/analysis/etc/algorithm_parameters/2015-11/kineticsTools/P5-C3.h5 \
# TODO: should i use 15/11 parameters ?

