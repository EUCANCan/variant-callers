#!/bin/bash
mkdir $WORKING_DIR/brass_6_3_4

# Link all NORMAL_SAMPLE TUMOR_SAMPLE files to the working directory
ln -s $NORMAL_SAMPLE* $WORKING_DIR/brass_6_3_4/
ln -s $TUMOR_SAMPLE* $WORKING_DIR/brass_6_3_4/

LOCAL_NORMAL_SAMPLE=$WORKING_DIR/brass_6_3_4/$(basename $NORMAL_SAMPLE)
LOCAL_TUMOR_SAMPLE=$WORKING_DIR/brass_6_3_4/$(basename $TUMOR_SAMPLE)

singularity exec -e $SINGULARITY_DIR/brass_6_3_4.sif bash -c "
# Create the .bam.bas files if they do not exist
if [ ! -f $LOCAL_NORMAL_SAMPLE.bas ]; then
    bam_stats -@ $NUM_CORES -i $LOCAL_NORMAL_SAMPLE -o $LOCAL_NORMAL_SAMPLE.bas
fi
if [ ! -f $LOCAL_TUMOR_SAMPLE.bas ]; then
    bam_stats -@ $NUM_CORES -i $LOCAL_TUMOR_SAMPLE -o $LOCAL_TUMOR_SAMPLE.bas
fi

brass.pl -o $WORKING_DIR/brass_6_3_4/all.vcf \
 -d $EXTRA_DATA_DIR/brass/$REF_VERSION/hiSeqDepth.bed \
 -vi $EXTRA_DATA_DIR/brass/viral.genomic.merged.fa.2bit \
 -ct $EXTRA_DATA_DIR/brass/$REF_VERSION/Human.CentTelo.tsv \
 -g_cache $EXTRA_DATA_DIR/brass/$REF_VERSION/Homo_sapiens.GRCh37.75.vagrent.cache.gz \
 -cytoband $EXTRA_DATA_DIR/brass/cytoband.txt \
 -ss $EXTRA_DATA_DIR/brass/dummy_ascat.txt \
 -microbe $EXTRA_DATA_DIR/brass/all_ncbi_bacteria \
 -gcbins $EXTRA_DATA_DIR/brass/$REF_VERSION/gcBins.bed.gz \
 -species human -assembly $REF_VERSION -protocol WGS -pl Illumina \
 -normal $LOCAL_NORMAL_SAMPLE -tumour $LOCAL_TUMOR_SAMPLE \
 -g $FASTA_REF -c $NUM_CORES
"

# Copy the result
cp $WORKING_DIR/brass_6_3_4/all.vcf/*.annot.vcf.gz $WORKING_DIR/brass_6_3_4/brass_6_3_4.vcf.gz

# Add PASS to the entries
singularity exec -e $SINGULARITY_DIR/brass_6_3_4.sif bash -c "
zcat $WORKING_DIR/brass_6_3_4/brass_6_3_4.vcf.gz | sed 's/\t\.\tSVTYPE/\tPASS\tSVTYPE/g' | gzip > $OUTPUT_DIR/brass_6_3_4.vcf.gz
"

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/brass_6_3_4.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/brass_6_3_4.vcf.gz is empty"
    exit 1
fi
