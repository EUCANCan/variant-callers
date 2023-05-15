#!/bin/bash
rm -rf $WORKING_DIR/strelka_2_9_10
mkdir $WORKING_DIR/strelka_2_9_10

singularity exec -e $SINGULARITY_DIR/strelka_2_9_10.sif sh -c "
/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py --normalBam=$NORMAL_SAMPLE --tumorBam=$TUMOR_SAMPLE --referenceFasta=$FASTA_REF --runDir=$WORKING_DIR/strelka_2_9_10
$WORKING_DIR/strelka_2_9_10/runWorkflow.py -m local -j $NUM_CORES
bcftools concat $WORKING_DIR/strelka_2_9_10/results/variants/somatic.indels.vcf.gz $WORKING_DIR/strelka_2_9_10/results/variants/somatic.snvs.vcf.gz --threads $NUM_CORES -a -O z -o $OUTPUT_DIR/strelka_2_9_10.vcf.gz
"

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/strelka_2_9_10.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/strelka_2_9_10.vcf.gz is empty"
    exit 1
fi