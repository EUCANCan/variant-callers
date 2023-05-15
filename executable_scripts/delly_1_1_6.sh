#!/bin/bash
module load bcftools/1.15.1
module load samtools

mkdir $WORKING_DIR/delly_1_1_6

singularity exec -e $SINGULARITY_DIR/delly_1_1_6.sif sh -c "
if [ -s  $WORKING_DIR/delly_1_1_6/delly_1_1_6_DEL.bcf.csi ]; then
    echo Skipping DEL
else
    echo Running DELLY on DEL
    delly call -x $EXTRA_DATA_DIR/delly/$REF_VERSION/human.excl.tsv -o $WORKING_DIR/delly_1_1_6/delly_1_1_6_DEL.bcf -t DEL -g $FASTA_REF $TUMOR_SAMPLE $NORMAL_SAMPLE &
fi
if [ -s  $WORKING_DIR/delly_1_1_6/delly_1_1_6_DUP.bcf.csi ]; then
    echo Skipping DUP
else
    echo Running DELLY on DUP
    delly call -x $EXTRA_DATA_DIR/delly/$REF_VERSION/human.excl.tsv -o $WORKING_DIR/delly_1_1_6/delly_1_1_6_DUP.bcf -t DUP -g $FASTA_REF $TUMOR_SAMPLE $NORMAL_SAMPLE &
fi
if [ -s  $WORKING_DIR/delly_1_1_6/delly_1_1_6_INV.bcf.csi ]; then
    echo Skipping INV
else
    echo Running DELLY on INV
    delly call -x $EXTRA_DATA_DIR/delly/$REF_VERSION/human.excl.tsv -o $WORKING_DIR/delly_1_1_6/delly_1_1_6_INV.bcf -t INV -g $FASTA_REF $TUMOR_SAMPLE $NORMAL_SAMPLE &
fi
if [ -s  $WORKING_DIR/delly_1_1_6/delly_1_1_6_BND.bcf.csi ]; then
    echo Skipping BND
else
    echo Running DELLY on BND
    delly call -x $EXTRA_DATA_DIR/delly/$REF_VERSION/human.excl.tsv -o $WORKING_DIR/delly_1_1_6/delly_1_1_6_BND.bcf -t BND -g $FASTA_REF $TUMOR_SAMPLE $NORMAL_SAMPLE &
fi
if [ -s  $WORKING_DIR/delly_1_1_6/delly_1_1_6_INS.bcf.csi ]; then
    echo Skipping INS
else
    echo Running DELLY on INS
    delly call -x $EXTRA_DATA_DIR/delly/$REF_VERSION/human.excl.tsv -o $WORKING_DIR/delly_1_1_6/delly_1_1_6_INS.bcf -t INS -g $FASTA_REF $TUMOR_SAMPLE $NORMAL_SAMPLE &
fi
wait

bcftools concat $WORKING_DIR/delly_1_1_6/delly_1_1_6_DEL.bcf $WORKING_DIR/delly_1_1_6/delly_1_1_6_INS.bcf $WORKING_DIR/delly_1_1_6/delly_1_1_6_DUP.bcf $WORKING_DIR/delly_1_1_6/delly_1_1_6_INV.bcf $WORKING_DIR/delly_1_1_6/delly_1_1_6_BND.bcf --threads $NUM_CORES -a -O b -o $WORKING_DIR/delly_1_1_6/delly_1_1_6_unfiltered.bcf
bcftools index $WORKING_DIR/delly_1_1_6/delly_1_1_6_unfiltered.bcf

# Get sample names from bam files
samtools view -H $NORMAL_SAMPLE | grep '^@RG' | sed 's/.*SM:\([^\t]*\).*/\1/g' | uniq > $WORKING_DIR/delly_1_1_6/normal_sample.txt
samtools view -H $TUMOR_SAMPLE | grep '^@RG' | sed 's/.*SM:\([^\t]*\).*/\1/g' | uniq > $WORKING_DIR/delly_1_1_6/tumor_sample.txt

# Create samples.tsv file with normal and tumor samples tab separated
paste $WORKING_DIR/delly_1_1_6/normal_sample.txt <(echo $'control') > $WORKING_DIR/delly_1_1_6/samples.tsv
paste $WORKING_DIR/delly_1_1_6/tumor_sample.txt <(echo $'tumor') >> $WORKING_DIR/delly_1_1_6/samples.tsv

delly filter -f somatic -o $WORKING_DIR/delly_1_1_6/delly_1_1_6.bcf -s $WORKING_DIR/delly_1_1_6/samples.tsv $WORKING_DIR/delly_1_1_6/delly_1_1_6_unfiltered.bcf
"

cp $WORKING_DIR/delly_1_1_6/delly_1_1_6.bcf $OUTPUT_DIR/delly_1_1_6.bcf

# If the output file does not exist or empty, exit with 1
if [ ! -s $OUTPUT_DIR/delly_1_1_6.bcf ]; then
    echo "ERROR: $OUTPUT_DIR/delly_1_1_6.bcf is empty"
    exit 1
fi
