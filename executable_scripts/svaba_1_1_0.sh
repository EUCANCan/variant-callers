#!/bin/bash
mkdir $WORKING_DIR/svaba_1_1_0

singularity exec -e $SINGULARITY_DIR/svaba_1_1_0.sif sh -c "
/svaba/bin/svaba run --override-reference-check -t $TUMOR_SAMPLE -n $NORMAL_SAMPLE -G $FASTA_REF -p $NUM_CORES -a $WORKING_DIR/svaba_1_1_0/svaba

# Compress in order to concat
bgzip -@ $NUM_CORES -f -k $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.indel.vcf
bcftools index -f $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.indel.vcf.gz
bgzip -@ $NUM_CORES -f -k $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.sv.vcf
bcftools index -f $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.sv.vcf.gz

# Concatenate
bcftools concat $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.indel.vcf.gz $WORKING_DIR/svaba_1_1_0/svaba.svaba.unfiltered.somatic.sv.vcf.gz --threads $NUM_CORES -a -O z -o $OUTPUT_DIR/svaba_1_1_0.vcf.gz
"

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/svaba_1_1_0.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/svaba_1_1_0.vcf.gz is empty"
    exit 1
fi
