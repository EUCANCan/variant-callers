#!/bin/bash
mkdir $WORKING_DIR/sage_3_0

JAVA_OPTS="-Xms4G -Xmx"$MAX_MEMORY"G"

singularity exec -e $SINGULARITY_DIR/sage_3_0.sif bash -c "
# Get sample name from normal and tumor files
samtools view -H $NORMAL_SAMPLE | grep '^@RG' | sed 's/.*SM:\([^\t]*\).*/\1/g' | uniq > $WORKING_DIR/sage_3_0/normal_sample.txt
samtools view -H $TUMOR_SAMPLE | grep '^@RG' | sed 's/.*SM:\([^\t]*\).*/\1/g' | uniq > $WORKING_DIR/sage_3_0/tumor_sample.txt

java ${JAVA_OPTS} -cp /sage_v3.0_rc3.jar com.hartwig.hmftools.sage.SageApplication \
    -threads $NUM_CORES \
    -reference \$(cat $WORKING_DIR/sage_3_0/normal_sample.txt) -reference_bam $NORMAL_SAMPLE \
    -tumor \$(cat $WORKING_DIR/sage_3_0/tumor_sample.txt) -tumor_bam $TUMOR_SAMPLE \
    -ref_genome_version $REF_VERSION \
    -ref_genome $FASTA_REF \
    -hotspots $EXTRA_DATA_DIR/sage/KnownHotspots.somatic.37.vcf.gz \
    -panel_bed $EXTRA_DATA_DIR/sage/ActionableCodingPanel.somatic.37.bed.gz \
    -high_confidence_bed $EXTRA_DATA_DIR/sage/NA12878_GIAB_highconf_IllFB-IllGATKHC-CG-Ion-Solid_ALLCHROM_v3.2.2_highconf.bed.gz \
    -ensembl_data_dir $EXTRA_DATA_DIR/sage/ensembl_data_cache \
    -out $WORKING_DIR/sage_3_0/sage_3_0.vcf.gz
"

cp $WORKING_DIR/sage_3_0/sage_3_0.vcf.gz $OUTPUT_DIR/sage_3_0.vcf.gz

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/sage_3_0.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/sage_3_0.vcf.gz is empty"
    exit 1
fi
