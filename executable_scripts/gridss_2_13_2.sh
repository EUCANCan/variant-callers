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

rm -rf $WORKING_DIR/gridss_2_13_2
mkdir $WORKING_DIR/gridss_2_13_2

JAVA_HEAP_SIZE=$MAX_MEMORY"G"

gridss -r $FASTA_REF \
  -o $WORKING_DIR/gridss_2_13_2/all.vcf --workingdir $WORKING_DIR/gridss_2_13_2 \
  -t $NUM_CORES \
  --jvmheap $JAVA_HEAP_SIZE \
  $NORMAL_SAMPLE $TUMOR_SAMPLE


# Get sample names from VCF header
grep '^#CHROM' $WORKING_DIR/gridss_2_13_2/all.vcf | cut -f 10 | sed 's/\t/\n/g' > $WORKING_DIR/gridss_2_13_2/normal_sample.txt
grep '^#CHROM' $WORKING_DIR/gridss_2_13_2/all.vcf | cut -f 11 | sed 's/\t/\n/g' > $WORKING_DIR/gridss_2_13_2/tumor_sample.txt

# Run gripss
JAVA_OPTS="-Xmx"$MAX_MEMORY"G"
java ${JAVA_OPTS} -jar $EXTRA_DATA_DIR/gridss2/gripss_2_2.jar \
  -sample $(cat $WORKING_DIR/gridss_2_13_2/tumor_sample.txt) \
  -reference $(cat $WORKING_DIR/gridss_2_13_2/normal_sample.txt) \
  -ref_genome_version $REF_VERSION \
  -ref_genome $FASTA_REF \
  -pon_sgl_file $EXTRA_DATA_DIR/gridss2/$REF_VERSION/gridss_pon_single_breakend.bed.gz \
  -pon_sv_file $EXTRA_DATA_DIR/gridss2/$REF_VERSION/gridss_pon_breakpoint.bedpe.gz \
  -known_hotspot_file $EXTRA_DATA_DIR/gridss2/$REF_VERSION/known_fusions.bedpe \
  -repeat_mask_file $EXTRA_DATA_DIR/gridss2/$REF_VERSION/repeats.fa.out.gz \
  -vcf $WORKING_DIR/gridss_2_13_2/all.vcf \
  -output_dir $WORKING_DIR/gridss_2_13_2/

cp $WORKING_DIR/gridss_2_13_2/*.gripss.vcf.gz $OUTPUT_DIR/gridss_2_13_2.vcf.gz

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/gridss_2_13_2.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/gridss_2_13_2.vcf.gz is empty"
    exit 1
fi
