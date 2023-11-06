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

mkdir $WORKING_DIR/cgppindel_3_9_0

pindel.pl \
     -simrep $EXTRA_DATA_DIR/cgppindel/simpleRepeats.bed.gz \
     -filter $EXTRA_DATA_DIR/cgppindel/genomicRules.lst \
     -genes $EXTRA_DATA_DIR/cgppindel/codingexon_regions.indel.bed.gz \
     -unmatched $EXTRA_DATA_DIR/cgppindel/pindel_np.gff3.gz \
     -softfil $EXTRA_DATA_DIR/cgppindel/softRules.lst \
     -badloci $EXTRA_DATA_DIR/cgppindel/hiSeqDepth.bed.gz \
     -assembly $REF_VERSION -species human -c $NUM_CORES \
     -r $FASTA_REF -t $TUMOR_SAMPLE -n $NORMAL_SAMPLE -o $WORKING_DIR/cgppindel_3_9_0 

bgzip -@ $NUM_CORES -c $WORKING_DIR/cgppindel_3_9_0/*.germline.bed > $WORKING_DIR/cgppindel_3_9_0/germline.bed.gz
tabix -p bed $WORKING_DIR/cgppindel_3_9_0/germline.bed.gz

cp $WORKING_DIR/cgppindel_3_9_0/germline.bed.gz $OUTPUT_DIR/cgppindel_3_9_0.germline.bed.gz
cp $WORKING_DIR/cgppindel_3_9_0/germline.bed.gz.tbi $OUTPUT_DIR/cgppindel_3_9_0.germline.bed.gz.tbi
cp $WORKING_DIR/cgppindel_3_9_0/*.flagged.vcf.gz $OUTPUT_DIR/cgppindel_3_9_0.vcf.gz

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/cgppindel_3_9_0.vcf.gz ]; then
    echo "ERROR: $OUTPUT_DIR/cgppindel_3_9_0.vcf.gz is empty"
    exit 1
fi
