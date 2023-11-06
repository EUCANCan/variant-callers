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

rm -rf $WORKING_DIR/strelka_2_9_10
mkdir $WORKING_DIR/strelka_2_9_10

/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py --normalBam=$NORMAL_SAMPLE --tumorBam=$TUMOR_SAMPLE --referenceFasta=$FASTA_REF --runDir=$WORKING_DIR/strelka_2_9_10
$WORKING_DIR/strelka_2_9_10/runWorkflow.py -m local -j $NUM_CORES
bcftools concat $WORKING_DIR/strelka_2_9_10/results/variants/somatic.indels.vcf.gz $WORKING_DIR/strelka_2_9_10/results/variants/somatic.snvs.vcf.gz --threads $NUM_CORES -a -O z -o $OUTPUT_DIR/strelka_2_9_10.vcf.gz


# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/strelka_2_9_10.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/strelka_2_9_10.vcf.gz is empty"
    exit 1
fi