#!/bin/bash
mkdir $WORKING_DIR/brass_6_3_4

singularity exec -e $EXECUTABLE_DIR/brass_6_3_4.sif sh -c "
brass.pl -o $WORKING_DIR/brass_6_3_4/all.vcf \
 -d $EXTRA_DATA_DIR/brass/$REF_VERSION/hiSeqDepth.bed \
 -vi $EXTRA_DATA_DIR/brass/viral.genomic.merged.fa.2bit \
 -ct $EXTRA_DATA_DIR/brass/$REF_VERSION/Human.CentTelo.tsv \
 -g_cache $EXTRA_DATA_DIR/brass/$REF_VERSION/Homo_sapiens.vagrent.cache.gz \
 -cytoband $EXTRA_DATA_DIR/brass/cytoband.txt \
 -ss $EXTRA_DATA_DIR/brass/dummy_ascat.txt \
 -microbe $EXTRA_DATA_DIR/brass/all_ncbi_bacteria \
 -gcbins $EXTRA_DATA_DIR/brass/$REF_VERSION/gcBins.bed \
 -species human -assembly $REF_VERSION -protocol WGS -pl Illumina \
 -normal $NORMAL_SAMPLE -tumour $TUMOR_SAMPLE -g $FASTA_REF -c $NUM_CORES
"

# Copy the result
cp $WORKING_DIR/brass_6_3_4/all.vcf/*.annot.vcf.gz $OUTPUT_DIR/brass_6_3_4.vcf

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/brass_6_3_4.vcf ]; then
    echo "ERROR: $OUTPUT_DIR/brass_6_3_4.vcf is empty"
    exit 1
fi
