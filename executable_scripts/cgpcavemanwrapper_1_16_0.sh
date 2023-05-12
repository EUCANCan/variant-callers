#!/bin/bash
mkdir $WORKING_DIR/cgpcavemanwrapper_1_16_0

# WARNING: Requires cgppindel_3_9_0.sh to be run first in order to read $OUTPUT_DIR/cgppindel_3_9_0.germline.bed.gz

singularity exec -e $EXECUTABLE_DIR/cgpcavemanwrapper_1_16_0.sif sh -c "
caveman.pl \
     -ig $EXTRA_DATA_DIR/cgpcavemanwrapper/HiDepth.tsv \
     -tc $EXTRA_DATA_DIR/cgpcavemanwrapper/empty.cn.bed -td 5 \
     -nc $EXTRA_DATA_DIR/cgpcavemanwrapper/empty.cn.bed -nd 2 \
     -b $EXTRA_DATA_DIR/cgpcavemanwrapper/flagging \
     -in $OUTPUT_DIR/cgppindel_3_9_0.germline.bed.gz \
     -u $EXTRA_DATA_DIR/cgpcavemanwrapper/unmatched \
     -c $EXTRA_DATA_DIR/cgpcavemanwrapper/flag.vcf.config.WGS.ini \
     -f $EXTRA_DATA_DIR/cgpcavemanwrapper/flag.to.vcf.convert.ini \
     -r $FASTA_REF.fai -tb $TUMOR_SAMPLE -nb $NORMAL_SAMPLE \
     -species-assembly $REF_VERSION -species human -seqType genome \
     -t $NUM_CORES -o $WORKING_DIR/cgpcavemanwrapper_1_16_0
"
cp $WORKING_DIR/cgpcavemanwrapper_1_16_0/*.flagged.muts.vcf.gz $OUTPUT_DIR/cgpcavemanwrapper_1_16_0.vcf.gz

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/cgpcavemanwrapper_1_16_0.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/cgpcavemanwrapper_1_16_0.vcf.gz is empty"
    exit 1
fi
