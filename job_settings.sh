SAMPLE=7515
CHEMISTRY="P6-C4"
ALL_FOFN=input_${SAMPLE}_${CHEMISTRY}.fofn

MAX_CHUNK=512

## When reference entry in line# $REF_LINE is REFERENCE, in the setting file,
## it will be replaced by REFERENCE specified here.
SETTINGS=Mapping.xml
REF_LINE=9
REFERENCE=/work/hacone/Reference/hg38/

## Comment out this to do something
#COLD_RUN=TRUE
BATCH_N=6
