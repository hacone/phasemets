#/bin/bash

SETUP=/bio/package/pacbio/smrtanalysis/current/etc/setup.sh

source ./job_settings.sh

#smrtpipe.py --version
#cmph5tools.py summarize data/aligned_reads.cmp.h5
#exit

FOFN=$1
. ${SETUP}
fofnToSmrtpipeInput.py ${FOFN} > input.xml

sed -e "${REF_LINE},${REF_LINE}s=REFERENCE=${REFERENCE}=" ${SETTINGS} > .settings.xml

if [[ $COLD_RUN ]]; then

echo <<EOL
smrtpipe.py --distribute --noreports \
 -D TMP=/work/hacone/tmp -D SHARED_DIR=/work/hacone/shareddir \
 --params=.settings.xml xml:input.xml
EOL

else
  smrtpipe.py --distribute --noreports \
   -D TMP=/work/hacone/tmp -D SHARED_DIR=/work/hacone/shareddir \
   --params=.settings.xml xml:input.xml
fi
