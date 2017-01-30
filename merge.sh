#!/bin/bash

# TODO: this should go into global settings
SETUP=/bio/package/pacbio/smrtanalysis/current/etc/setup.sh

count=0

CBRD=$(pwd)/cmp_by_ref
JOBD=$(pwd)/job_scripts

mkdir -p ${CBRD}/Merged/

# need to comment out this in second trial
find ${CBRD}/Movie/* | grep .cmp.h5 | grep chr > ${CBRD}/CmpList.dat
cat ${CBRD}/CmpList.dat | sed -e "s/.*\///; s/.cmp.h5//" | sort | uniq > ${CBRD}/RefList.dat

while read ref; do

  JOBSH=${JOBD}/mg_${ref}.sh

  echo "#!/bin/bash" > ${JOBSH}
  echo "source ${SETUP}" >> ${JOBSH}
  echo "cmph5tools.py merge --outFile ${CBRD}/Merged/${ref}.cmp.h5 \\" >> ${JOBSH}
  echo "`grep ${ref}.cmp.h5 ${CBRD}/CmpList.dat | tr \"\\n\" \" \"`" >> ${JOBSH}
  echo "echo \"merged for ${ref}\"" >> ${JOBSH}
  echo "cmph5tools.py sort --deep --inPlace ${CBRD}/Merged/${ref}.cmp.h5" >> ${JOBSH}
  echo "echo \"sorted for ${ref}\"" >> ${JOBSH}
  echo "# h5repack ${CBRD}/Merged/${ref}.cmp.h5" >> ${JOBSH}
  echo "echo \"all done\"" >> ${JOBSH}
  
  count=$(( $count +1 ))
  hn=`printf "%03d" ${count}`
# make sure the command line is not too long... (!!!)
  if [ `grep ${ref}.cmp.h5 ${CBRD}/CmpList.dat | wc -c` -lt $(( `getconf ARG_MAX` - 500 )) ]; then
    qsub -q all.q -S /bin/bash \
    -o ${JOBD}/mg_${ref}.out -e ${JOBD}/mg_${ref}.err -l "hostname=hpg${hn}" ${JOBSH} 
    echo "job submitted for ${ref}."
  else
    echo "too long args for ${ref}. job was not submitted."
  fi

done < ${CBRD}/RefList.dat
