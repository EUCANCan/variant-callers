# PLATFORM NAME - Variant callers<!-- omit in toc -->

This repository contains the scripts to run the variant callers used in PLATFORM NAME. The variant callers are executed from Bash scripts that use Singularity containers (sometimes it might be necessary to convert the Docker containers to Singularity containers, see [Useful information](#useful-information)). The scripts are located in the [`executable_scripts/`](executable_scripts/) folder of this repository.

The containers references are available in the [variant caller list](#variant-callers-list) below. Some of the containers recipies are available in this repository, while others are available in external repositories. For the latter, the link to the repository is provided.

The scripts for running the variant callers are Bash scripts that can be executed directly from the command line in almost any Unix-based system. The only dependency is Singularity ([`singularity-ce`](https://sylabs.io/singularity/) version +3.9.0).

## Table of Contents<!-- omit in toc -->
- [Variant callers list](#variant-callers-list)
- [Executing the variant callers](#executing-the-variant-callers)
  - [Environment variables](#environment-variables)
  - [Extra data](#extra-data)
  - [Example of execution](#example-of-execution)
- [Useful information](#useful-information)
  - [Building a Singularity image from a recipe](#building-a-singularity-image-from-a-recipe)
  - [Converting a Docker image to a Singularity image](#converting-a-docker-image-to-a-singularity-image)


## Variant callers list

| Variant caller                                                                                                                   | Variants called | Version             | Singularity/Docker image/recipe                                                                                                                                                                                                                                | Notes                                          |
| -------------------------------------------------------------------------------------------------------------------------------- | --------------- | ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| [cgpCaVEManWrapper](https://github.com/cancerit/cgpCaVEManWrapper)                                                               | SNV             | 1.6.0               | [Dockerfile from repository](https://github.com/cancerit/cgpCaVEManWrapper/tree/1.16.0)                                                                                                                                                                        | Requires cgpPindel v3.9.0 to be executed first |
| [MuSE](https://github.com/wwylab/MuSE)                                                                                           | SNV             | 2.0                 | [Dockerfile from repository](https://github.com/wwylab/MuSE/tree/0c1be9aba1a9772fcab33dca49805f9ffaa3370c)                                                                                                                                                     | Does not work with CRAM files                  |
| [Shimmer](https://github.com/nhansen/Shimmer)                                                                                    | SNV             |                     | [Singularity recipe (custom)](./container_recipies/shimmer.def)                                                                                                                                                                                                | Does not work with CRAM files                  |
| [Mutect2 (from GATK)](https://gatk.broadinstitute.org/hc/en-us/articles/360037593851-Mutect2)                                    | SNV/Indel       | 4.2.6.1             | [Docker container](https://hub.docker.com/layers/broadinstitute/gatk/4.2.6.1/images/sha256-21c3cb43b7d11891ed4b63cc7274f20187f00387cfaa0433b3e7991b5be34dbe)                                                                                                   |                                                |
| [SAGE](https://github.com/hartwigmedical/hmftools/blob/master/sage)                                                              | SNV/Indel       | 3.0                 | [Singularity recipe (custom)](./container_recipies/sage_3_0.def)                                                                                                                                                                                               |                                                |
| [Strelka2](https://github.com/Illumina/strelka)                                                                                  | SNV/Indel       | 2.9.10              | [Singularity recipe (custom)](./container_recipies/strelka_2_9_10.def)                                                                                                                                                                                         |                                                |
| [cgpPindel](https://github.com/cancerit/cgpPindel)                                                                               | Indel           | 3.9.0               | [Docker container](https://quay.io/repository/wtsicgp/cgppindel?tab=tags&tag=3.9.0)                                                                                                                                                                            |                                                |
| [SvABA](https://github.com/walaj/svaba)                                                                                          | Indel/SV        | 1.1.0               | [Singularity recipe (custom)](./container_recipies/svaba_1_1_0.def)                                                                                                                                                                                            |                                                |
| [BRASS](https://github.com/cancerit/BRASS)                                                                                       | SV              | 6.3.4               | [Docker container](http://quay.io/wtsicgp/brass:6.3.4)                                                                                                                                                                                                         |                                                |
| [Delly](https://github.com/dellytools/delly)                                                                                     | SV              | 1.1.6               | [Singularity recipe (custom)](./container_recipies/delly_1_1_6.def)                                                                                                                                                                                            |                                                |
| [GRIDSS2](https://github.com/PapenfussLab/gridss) (with [GRIPSS](https://github.com/hartwigmedical/hmftools/tree/master/gripss)) | SV              | 2.13.2 (GRIPSS 2.2) | [Docker container](https://hub.docker.com/layers/gridss/gridss/2.13.2/images/sha256-14915db77af89b1a3ac0b705362fefb6be12ae0f80b1f8e2221656375a0e0d86) / [GRIPSS JAR](https://github.com/hartwigmedical/hmftools/releases/download/gripss-v2.2/gripss_v2.2.jar) | Requires `gripss_2_2.jar`                      |
| [Manta](https://github.com/Illumina/manta)                                                                                       | SV              | 1.6.0               | [Singularity recipe (custom)](./container_recipies/manta_1_6_0.def)                                                                                                                                                                                            |                                                |


## Executing the variant callers

All the scripts to execute the variant callers are located in the [`executable_scripts/`](executable_scripts/) folder of this repository. The scripts are named after the variant caller they execute and its version. For example, the script to execute MuSE v2.0 is located in [`executable_scripts/muse_2.0.sh`](executable_scripts/muse_2.0.sh).

All scripts require the singularity image to be located in the `$EXECUTABLE_DIR` folder with the same name as the script but with the `.sif` extension. For example, the script [`executable_scripts/muse_2.0.sh`](executable_scripts/muse_2.0.sh) requires the singularity image to be located in `$EXECUTABLE_DIR/muse_2.0.sif`.

_Note: GRIDSS2 also requires a JAR file named `gripss_X_X.jar` to be located in the `$EXECUTABLE_DIR` folder._

### Environment variables

All the scripts require the following environment variables to be set:

```bash
$WORKING_DIR # path to working directory
$OUTPUT_DIR # path to output directory
$EXECUTABLE_DIR # path to the parent folder of the singularity image
$EXTRA_DATA_DIR # path to extra data directory
$REF_VERSION # reference version (i.e. 37)
$NORMAL_SAMPLE # path to normal sample SAM/BAM/CRAM file
$TUMOR_SAMPLE # path to tumor sample SAM/BAM/CRAM file
$FASTA_REF # path to reference FASTA file
$NUM_CORES # number of cores to use
$MAX_MEMORY # maximum memory to use (in GB) (i.e 8)
```

### Extra data

Some variant callers require extra data to be executed. The extra data required by each variant caller is available in the [`required_extra_data/`](required_extra_data/) folder of this repository. If you were running the variant caller from the root of this repository, you could use the following command to set the `$EXTRA_DATA_DIR` environment variable:

```bash
export EXTRA_DATA_DIR=required_extra_data
```

_Note: Due to size limitations, some files are not available in this repository and need to be downloaded from external sources. For these cases, a file with the same name but ending with `.download` will be present instead. This file contains the instructions and links to download the file._

### Example of execution

The following example shows how to execute any of the variant callers:

```bash
export WORKING_DIR=/path/to/working/directory
export OUTPUT_DIR=/path/to/output/directory
export EXECUTABLE_DIR=./singularity_containers
export EXTRA_DATA_DIR=./required_extra_data
export REF_VERSION=37
export NORMAL_SAMPLE=/path/to/normal/sample.bam
export TUMOR_SAMPLE=/path/to/tumor/sample.bam
export FASTA_REF=/path/to/reference.fasta
export NUM_CORES=8
export MAX_MEMORY=32

bash ./executable_scripts/variant_caller_X_X_X.sh
```

## Useful information

### Building a Singularity image from a recipe

To build a Singularity image from a recipe, you can use the following command (it requires root privileges):

```bash
sudo singularity build <image_name>.sif <recipe_file>
```

### Converting a Docker image to a Singularity image

To convert a Docker image to a Singularity image, you first must save the Docker image to a file:

```bash
docker save <image_name>:<image_tag> > <image_name>_<image_tag>.tar
```

Then, you can convert the Docker image to a Singularity image:

```bash
singularity build <image_name>_<image_tag>.sif docker-archive://<image_name>_<image_tag>.tar
```