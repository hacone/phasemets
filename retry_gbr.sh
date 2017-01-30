#!/bin/bash

DRYRUN=0

for sh in $( ls -lahSr job_scripts/gbr*.err | gawk '$5!=0{print $10}' | sed -e "s#.*/##; s/.err/.sh/" ); do

    sh=$(pwd)/job_scripts/${sh}
    d=$( head -n 3 ${sh} | tail -n 1 ); d=${d##cd }

    echo ${sh}

    if [[ $DRYRUN == 0 ]]; then
      echo "clearing remains for ${sh}..."

      rm "${d}"chr*.cmp.h5
      rm ${sh%%.sh}.out ${sh%%.sh}.err

      qsub -q all.q -S /bin/bash \
      -o ${sh%%.sh}.out -e ${sh%%.sh}.err ${sh}
    fi
      

done
