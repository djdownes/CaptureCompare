#!/bin/bash

##########################################################################
#                                                                        #
# You can fill the below, to match your genome reference file locations  # 
# OR                                                                     #
# copy the genomeBuildSetup.sh file from your CCseqBasic installation    #
# to become the /config/genomeBuildSetup.sh file of CaptureCompare       #
#                                                                        #
# Copyright 2017, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
#                                                                        #
##########################################################################

setGenomeLocations(){
    

# This is the CONFIGURATION FILE to set up your GENOME INDICES ( conf/genomeBuildSetup.sh )

# Fill the locations of :

# - whole genome fasta files
# - ucsc chromosome size files 
# - genome digest files (optional, but will make the runs faster)

# As given in below examples


# #############################################################################
# SUPPORTED GENOMES 
# #############################################################################

# Add and remove genomes via this list.
# If user tries to use another genome (not listed here), the run is aborted with "genome not supported" message.

supportedGenomes[0]="mm9"
supportedGenomes[1]="mm10"
supportedGenomes[2]="hg18"
supportedGenomes[3]="hg19"

# The above genomes should have :
# 1) whole genome fasta files
# 2) UCSC genome sizes
# 3) genome digest files for dpnII and nlaIII and hindIII (optional - but makes runs faster).
#     These can be produced with the captureCompare during a regular run, with flag --savegenomedigest

# Fill these below !

# #############################################################################
# WHOLE GENOME FASTA FILES
# #############################################################################

# These are the whole genome fasta files, against which the bowtie1 indices were built, in UCSC coordinate set (not ENSEMBLE coordinates)
# These need to correspond to the UCSC chromosome sizes files (below)

# These can be symbolic links to the central copies of the indices.
# By default these are 

WholeGenomeFASTA[0]="/databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[1]="/databank/igenomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[2]="/databank/igenomes/Homo_sapiens/UCSC/hg18/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[3]="/databank/igenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa"

# The indices in the WholeGenomeFASTA array refer to genome names in supportedGenomes array (top of page).

# Not all of them need to exist : only the ones you will be using.
# The pipeline checks that this file exists, before proceeding with the analysis.

# When adding new genomes : remember to update the "supportedGenomes" list above as well !

# #############################################################################
# UCSC GENOME SIZES
# #############################################################################

# The UCSC genome sizes, for ucsctools .
# By default these are located in the 'conf/UCSCgenomeSizes' folder (relative to location of CCseqBasic4.sh main script) .
# All these are already there - they come with the CCseqBasic4 codes.

# Change the files / paths below, if you want to use your own versions of these files. 

# These can be fetched with ucsctools :
# module load ucsctools
# fetchChromSizes mm9 > mm9.chrom.sizes

UCSC[0]="${confFolder}/UCSCgenomeSizes/mm9.chrom.sizes"
UCSC[1]="${confFolder}/UCSCgenomeSizes/mm10.chrom.sizes"
UCSC[2]="${confFolder}/UCSCgenomeSizes/hg18.chrom.sizes"
UCSC[3]="${confFolder}/UCSCgenomeSizes/hg19.chrom.sizes"

# The indices in the UCSC array refer to genome names in supportedGenomes array (top of page).

# Not all of them need to exist : only the ones you will be using.
# The pipeline checks that at least one index file exists, before proceeding with the analysis

# When adding new genomes : remember to update the "supportedGenomes" list above (top of this file) as well !


# #############################################################################
# GENOME DIGEST FILES for dpnII and nlaIII (optional - but makes runs faster)
# #############################################################################

# To turn this off, set :
# CaptureDigestPath="NOT_IN_USE"

CaptureDigestPath="/home/molhaem2/telenius/CCseqBasic/digests"

# If you have this set for your CCseqBasic - you can use the same folder here.


}

