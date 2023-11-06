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

mkdir $WORKING_DIR/svaba_1_1_0

/svaba/bin/svaba run --override-reference-check -t $TUMOR_SAMPLE -n $NORMAL_SAMPLE -G $FASTA_REF -p $NUM_CORES -a $WORKING_DIR/svaba_1_1_0/svaba

# Compress in order to concat
bgzip -@ $NUM_CORES -c $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.indel.vcf > $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.indel.vcf.gz
bcftools index -f $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.indel.vcf.gz
bgzip -@ $NUM_CORES -c $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.sv.vcf > $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.sv.vcf.gz
bcftools index -f $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.sv.vcf.gz

# Concatenate
bcftools concat $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.indel.vcf.gz $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.sv.vcf.gz --threads $NUM_CORES -a -O z -o $OUTPUT_DIR/svaba_1_1_0.vcf.gz

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/svaba_1_1_0.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/svaba_1_1_0.vcf.gz is empty"
    exit 1
fi
