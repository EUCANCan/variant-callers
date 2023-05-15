#!/bin/bash

# WARNING: Does not work with CRAM

rm -rf $WORKING_DIR/muse_2_0
mkdir $WORKING_DIR/muse_2_0

singularity exec -e $SINGULARITY_DIR/muse_2_0.sif sh -c "
/MuSE/bin/MuSE call -f $FASTA_REF -n $NUM_CORES -O $WORKING_DIR/muse_2_0/call $TUMOR_SAMPLE $NORMAL_SAMPLE || exit 1
/MuSE/bin/MuSE sump -I $WORKING_DIR/muse_2_0/call.MuSE.txt -G -O $WORKING_DIR/muse_2_0/muse_2_0.vcf -D $EXTRA_DATA_DIR/muse/$REF_VERSION/dbSNP.gz
"
cp $WORKING_DIR/muse_2_0/muse_2_0.vcf $OUTPUT_DIR/muse_2_0.vcf

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/muse_2_0.vcf ]; then
    echo "ERROR: $OUTPUT_DIR/muse_2_0.vcf is empty"
    exit 1
fi
