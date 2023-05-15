#!/bin/bash
mkdir $WORKING_DIR/gatk_4_2_6_1

# Run in parallel
singularity exec -e $SINGULARITY_DIR/gatk_4_2_6_1.sif sh -c "
samtools view -H $NORMAL_SAMPLE | grep '^@RG' | sed 's/.*SM:\([^\t]*\).*/\1/g | uniq > $WORKING_DIR/gatk_4_2_6_1/normal_sample.txt

cut -f1 $FASTA_REF.fai | xargs -n 1 -P $NUM_CORES -I {} gatk Mutect2 -L {} -R $FASTA_REF -I $NORMAL_SAMPLE -I $TUMOR_SAMPLE --normal-sample $(cat $WORKING_DIR/gatk_4_2_6_1/normal_sample.txt) -O $WORKING_DIR/gatk_4_2_6_1/{}.somatic.vcf.gz
"

# Every contig in the reference must have a non-empty vcf file
for contig in $(cut -f1 $FASTA_REF.fai); do
  if [ ! -s $WORKING_DIR/gatk_4_2_6_1/$contig.somatic.vcf.gz.stats ]; then
    echo "ERROR: $contig.somatic.vcf.gz is empty"
    exit 1
  fi
done

ls $WORKING_DIR/gatk_4_2_6_1/*.somatic.vcf.gz.stats | head -c -1 > $WORKING_DIR/gatk_4_2_6_1/stats.list
ls $WORKING_DIR/gatk_4_2_6_1/*.somatic.vcf.gz | head -c -1 > $WORKING_DIR/gatk_4_2_6_1/vcf.list

singularity exec -e $SINGULARITY_DIR/gatk_4_2_6_1.sif sh -c "
gatk MergeVcfs -I $WORKING_DIR/gatk_4_2_6_1/vcf.list -O $WORKING_DIR/gatk_4_2_6_1/merged.vcf.gz
gatk MergeMutectStats -stats $WORKING_DIR/gatk_4_2_6_1/stats.list -O $WORKING_DIR/gatk_4_2_6_1/merged.vcf.gz.stats
gatk --java-options '-Xmx"$MAX_MEMORY"G' FilterMutectCalls -R $FASTA_REF -V $WORKING_DIR/gatk_4_2_6_1/merged.vcf.gz -O $WORKING_DIR/gatk_4_2_6_1/merged.filtered.vcf.gz
"

if gzip -t $WORKING_DIR/gatk_4_2_6_1/merged.filtered.vcf.gz; then
  echo "SUCCESS"
else
  echo "ERROR: merged.filtered.vcf.gz is not a valid gzip file"
  exit 1
fi

cp $WORKING_DIR/gatk_4_2_6_1/merged.filtered.vcf.gz $OUTPUT_DIR/gatk_4_2_6_1.vcf.gz

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/gatk_4_2_6_1.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/gatk_4_2_6_1.vcf.gz is empty"
    exit 1
fi
