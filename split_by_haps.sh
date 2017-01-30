#!/bin/bash
WDIR=/work/hacone/AshTrioSon/prima

#for cnth in $( ls ${WDIR}/ByMovie/*.counthap | head -n 5); do
for cnth in $( ls ${WDIR}/ByMovie/*.counthap ); do
  FileId=${cnth%.counthap}; FileId=${FileId##*/}
  echo ${FileId}

  JSH=${WDIR}/Jobs/sbh_${FileId}.sh
  echo "#!/bin/bash" > $JSH
  echo "source /bio/package/pacbio/smrtanalysis/current/etc/setup.sh" >> $JSH

  for refs in $( gawk 'NR>3&&($3+$4)>0{ print $1 }' ${cnth} | sort | uniq ); do
    echo ${refs}

    ## extraction for left haplo
    ResultDir=${WDIR}/ByRefHap/${refs}_left
    mkdir -p ${ResultDir}
    gawk 'NR>3&&$1=="'${refs}'"&&($3-$4)>0{ gsub(/.*\//, "", $2); print }' ${cnth} > ${ResultDir}/${FileId}.dat

      ARG=""; line_count=0; chunk=1
      while read line ; do
        line_count=$(( $line_count + 1 ))
        set ${line}; HN=$2; ARG=${ARG}"(HoleNumber==${HN})|"
        if [ $line_count -gt 300 ]; then
          ARG=${ARG%|}
          echo "cmph5tools.py select --where \"${ARG}\" --outFile ${ResultDir}/${FileId}_${chunk}.cmp.h5 ${WDIR}/ByMovie/${FileId}.cmp.h5" >> $JSH
          ARG=""; line_count=0; chunk=$(( $chunk + 1 ))
        fi
      done < ${ResultDir}/${FileId}.dat

    ARG=${ARG%|}
    if [ "$ARG" != "" ]; then
      echo "cmph5tools.py select --where \"${ARG}\" --outFile ${ResultDir}/${FileId}_${chunk}.cmp.h5 ${WDIR}/ByMovie/${FileId}.cmp.h5" >> $JSH
    fi

    ## extraction for right haplo
    ResultDir=${WDIR}/ByRefHap/${refs}_right
    mkdir -p ${ResultDir}
    gawk 'NR>3&&$1=="'${refs}'"&&($4-$3)>0{ gsub(/.*\//, "", $2); print }' ${cnth} > ${ResultDir}/${FileId}.dat

      ARG=""; line_count=0; chunk=1
      while read line ; do
        line_count=$(( $line_count + 1 ))
        set ${line}; HN=$2; ARG=${ARG}"(HoleNumber==${HN})|"
        if [ $line_count -gt 300 ]; then
          ARG=${ARG%|}
          echo "cmph5tools.py select --where \"${ARG}\" --outFile ${ResultDir}/${FileId}_${chunk}.cmp.h5 ${WDIR}/ByMovie/${FileId}.cmp.h5" >> $JSH
          ARG=""; line_count=0; chunk=$(( $chunk + 1 ))
        fi
      done < ${ResultDir}/${FileId}.dat

    ARG=${ARG%|}
    if [ "$ARG" != "" ]; then
      echo "cmph5tools.py select --where \"${ARG}\" --outFile ${ResultDir}/${FileId}_${chunk}.cmp.h5 ${WDIR}/ByMovie/${FileId}.cmp.h5" >> $JSH
    fi

  done

  if [ $( cat ./err/sbh_${FileId}.err | wc -l ) -gt 0 ]; then
    echo "rerun for $FileId"
    rm ${WDIR}/ByRefHap/*/${FileId}.cmp.h5
    qsub -q pacbio.q -S /bin/bash \
    -o ${JSH%%.sh}.out -e ${JSH%%.sh}.err ${JSH}
  fi

done

exit

echo "Now merging for all the movies ..."
cmph5tools.py merge \
  --outFile ${WDIR}/chr${CHROM}_h${HAPLO}.cmp.h5 ${CHRHDIR}/*.cmp.h5
