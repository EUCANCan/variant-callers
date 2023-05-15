#!/bin/bash
mkdir $WORKING_DIR/brass_6_3_4

# Link normal and tumor samples to the working directory
ln -s $NORMAL_SAMPLE $WORKING_DIR/brass_6_3_4/normal.bam
ln -s $TUMOR_SAMPLE $WORKING_DIR/brass_6_3_4/tumor.bam
# Link the .bam.bas files to the working directory if they exist
if [ -f $NORMAL_SAMPLE.bas ]; then
    ln -s $NORMAL_SAMPLE.bas $WORKING_DIR/brass_6_3_4/normal.bam.bas
fi
if [ -f $TUMOR_SAMPLE.bas ]; then
    ln -s $TUMOR_SAMPLE.bas $WORKING_DIR/brass_6_3_4/tumor.bam.bas
fi

singularity exec -e $SINGULARITY_DIR/brass_6_3_4.sif bash -c "
# Create the .bam.bas files if they do not exist
if [ ! -f $WORKING_DIR/brass_6_3_4/normal.bam.bas ]; then
    bam_stats -@ $NUM_CORES -i $WORKING_DIR/brass_6_3_4/normal.bam -o $WORKING_DIR/brass_6_3_4/normal.bam.bas
fi
if [ ! -f $WORKING_DIR/brass_6_3_4/tumor.bam.bas ]; then
    bam_stats -@ $NUM_CORES -i $WORKING_DIR/brass_6_3_4/tumor.bam -o $WORKING_DIR/brass_6_3_4/tumor.bam.bas
fi

brass.pl -o $WORKING_DIR/brass_6_3_4/all.vcf \
 -d $EXTRA_DATA_DIR/brass/$REF_VERSION/hiSeqDepth.bed \
 -vi $EXTRA_DATA_DIR/brass/viral.genomic.merged.fa.2bit \
 -ct $EXTRA_DATA_DIR/brass/$REF_VERSION/Human.CentTelo.tsv \
 -g_cache $EXTRA_DATA_DIR/brass/$REF_VERSION/Homo_sapiens.vagrent.cache.gz \
 -cytoband $EXTRA_DATA_DIR/brass/cytoband.txt \
 -ss $EXTRA_DATA_DIR/brass/dummy_ascat.txt \
 -microbe $EXTRA_DATA_DIR/brass/all_ncbi_bacteria \
 -gcbins $EXTRA_DATA_DIR/brass/$REF_VERSION/gcBins.bed.gz \
 -species human -assembly $REF_VERSION -protocol WGS -pl Illumina \
 -normal $WORKING_DIR/brass_6_3_4/normal.bam -tumour $WORKING_DIR/brass_6_3_4/tumor.bam \
 -g $FASTA_REF -c $NUM_CORES
"

# Copy the result
cp $WORKING_DIR/brass_6_3_4/all.vcf/*.annot.vcf.gz $OUTPUT_DIR/brass_6_3_4.vcf

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/brass_6_3_4.vcf ]; then
    echo "ERROR: $OUTPUT_DIR/brass_6_3_4.vcf is empty"
    exit 1
fi
