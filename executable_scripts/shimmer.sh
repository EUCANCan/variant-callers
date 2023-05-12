#!/bin/bash

# WARNING: Does not work with CRAM

mkdir $WORKING_DIR/shimmer

# exit when any command fails
set -e

# Run in parallel
singularity exec -e $EXECUTABLE_DIR/shimmer.sif bash -c "
set -e
cut -f1 $FASTA_REF.fai | xargs -n 1 -P $NUM_CORES -I {} bash -c '
if [ -s  $WORKING_DIR/shimmer/partial_{}/somatic_diffs.vcf.gz ]; then
    echo Skipping chromosome {}
else 
    echo Running Shimmer on chromosome {}
    shimmer.pl --ref $FASTA_REF --region {} --outdir $WORKING_DIR/shimmer/partial_{} $NORMAL_SAMPLE $TUMOR_SAMPLE
fi
'

for chrom in $(cut -f1 $FASTA_REF.fai)
do
    bcftools view $WORKING_DIR/shimmer/partial_$chrom/somatic_diffs.vcf -O z -o $WORKING_DIR/shimmer/partial_$chrom/somatic_diffs.vcf.gz
    bcftools index -f $WORKING_DIR/shimmer/partial_$chrom/somatic_diffs.vcf.gz
done

bcftools concat $WORKING_DIR/shimmer/partial_*/somatic_diffs.vcf.gz --threads $NUM_CORES -a -O z -o $WORKING_DIR/shimmer/shimmer.vcf.gz
"

cp $WORKING_DIR/shimmer/shimmer.vcf.gz $OUTPUT_DIR/shimmer.vcf.gz

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/shimmer.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/shimmer.vcf.gz is empty"
    exit 1
fi
