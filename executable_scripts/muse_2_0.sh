#!/bin/bash
# Check if the number of arguments is correct
if [ $# -ne 9 ]; then
    echo "ERROR: Wrong number of arguments"
    echo "USAGE: brass_6_3_4.sh WORKING_DIR OUTPUT_DIR EXTRA_DATA_DIR REF_VERSION NORMAL_SAMPLE TUMOR_SAMPLE FASTA_REF NUM_CORES MAX_MEMORY"
    exit 1
fi
WORKING_DIR=$1
OUTPUT_DIR=$2
EXTRA_DATA_DIR=$3
REF_VERSION=$4
NORMAL_SAMPLE=$5
TUMOR_SAMPLE=$6
FASTA_REF=$7
NUM_CORES=$8
MAX_MEMORY=$9

# WARNING: Does not work with CRAM

rm -rf $WORKING_DIR/muse_2_0
mkdir $WORKING_DIR/muse_2_0

/MuSE/bin/MuSE call -f $FASTA_REF -n $NUM_CORES -O $WORKING_DIR/muse_2_0/call $TUMOR_SAMPLE $NORMAL_SAMPLE || exit 1
/MuSE/bin/MuSE sump -I $WORKING_DIR/muse_2_0/call.MuSE.txt -G -O $WORKING_DIR/muse_2_0/muse_2_0.vcf -D $EXTRA_DATA_DIR/muse/$REF_VERSION/dbSNP.gz

cp $WORKING_DIR/muse_2_0/muse_2_0.vcf $OUTPUT_DIR/muse_2_0.vcf

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/muse_2_0.vcf ]; then
    echo "ERROR: $OUTPUT_DIR/muse_2_0.vcf is empty"
    exit 1
fi
