#!/bin/bash

JOBD=/work/hacone/AshTrioSon/prima/Jobs
WDIR=/work/hacone/AshTrioSon/prima/ByMovie

for Cmp in $( ls ByMovie/*.cmp.h5 ); do

  FileId=${Cmp%%.cmp.h5}
  FileId=${FileId##ByMovie/}

  if [ ! -e ByMovie/${FileId}.sam ]; then

    echo "do for ${FileId}"

    JSH=${JOBD}/Cmp2Sam_${FileId}.sh
    echo "#!/bin/bash" > $JSH
    echo "source /bio/package/pacbio/smrtanalysis/current/etc/setup.sh" >> $JSH
    echo "pbsamtools --outfile ${WDIR}/${FileId}.sam ${WDIR}/${FileId}.cmp.h5" >> $JSH
    echo "echo \"done\"" >> $JSH

    #qsub -q all.q -S /bin/bash \
    qsub -q pacbio.q -S /bin/bash \
    -o ${JOBD}/Cmp2Sam_${FileId}.out -e ${JOBD}/Cmp2Sam_${FileId}.err ${JSH}

  fi

done
