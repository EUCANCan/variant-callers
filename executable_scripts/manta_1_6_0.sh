#!/bin/bash
rm -rf $WORKING_DIR/manta_1_6_0
mkdir $WORKING_DIR/manta_1_6_0

singularity exec -e $EXECUTABLE_DIR/manta_1_6_0.sif sh -c "
/manta-1.6.0.centos6_x86_64/bin/configManta.py --normalBam=$NORMAL_SAMPLE --tumorBam=$TUMOR_SAMPLE --referenceFasta=$FASTA_REF --runDir=$WORKING_DIR/manta_1_6_0
$WORKING_DIR/manta_1_6_0/runWorkflow.py -j $NUM_CORES
"
cp $WORKING_DIR/manta_1_6_0/results/variants/somaticSV.vcf.gz $OUTPUT_DIR/manta_1_6_0.vcf.gz

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/manta_1_6_0.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/manta_1_6_0.vcf.gz is empty"
    exit 1
fi
