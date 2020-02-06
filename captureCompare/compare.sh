#!/bin/bash
#$ -cwd

############################
###     Input Options    ###
############################

# Choice of comparison (either "2way" or "3way")                #Do I actually use this???, I think I worked around having to specify?
analysis=""

# Directory containing 6/9 run files with structure described in README.md.
path="/path/to/run/directory"

# Desired output name of samples with the exact name of the respective input folders.
sample1="sample_1_freefrom"
sample1Directories="sample1_dir1,sample1_dir2,sample1_dir3"

sample2="sample_2_freefrom"
sample2Directories="sample2_dir1,sample2_dir2,sample2_dir3"

sample3="sample_3_freefrom"                                             #if running 2way leave "" blank
sample3Directories="sample3_dir1,sample3_dir2,sample3_dir3"             #if running 2way leave "" blank

# Name for the analysis run: e.g. "GWAS_Promoter"
name="FREEFORM"

# Genome (supports hg18,hg19,mm9,mm10)
genome="hg19"

# CaptureC analyser version (Supports any version with output strcuture: F6_greenGraphs_combined_Samples_Version format)
version="Cb5"

# Path to file containing viewpoints and windowing parameters -
# Format: Viewpoint    Chr Frag_start  Frag_stop Exlusion_Start Exlusion_Stop Plot_Region_Start Plot_Region_Stop Bin_Size Window_size
parameters="/path/to/parameters/file/eg/BIN/Sample/Parameters.txt"


# Path to where you would like the public UCSC hub to be made
public="/path/to/where/you/want/your/hub"

# Name of enzyme used: supports, dpnII, nlaIII, hindIII
enzyme="dpnII"

#====================================================#

### Run Analysis

#====================================================#

CompareShell="/path/to/the/main/pipe/shell/cis3way.sh"

#Default annotation for plots is ref seq genes but any bed file can be inserted
annotation="/path/to/desired/bed/format/RefSeqGenes_${genome}.bed"

# We are now here
rundir=$( pwd )
echo "Running ${CompareShell} in ${rundir}"

# Print run command
echo "${CompareShell} --analysis=${analysis} --path=${path} --sample1=${sample1} --sample2=${sample2} --sample3=${sample3} --directories=${sample1Directories},${sample2Directories},${sample3Directories} --name=${name} --genome=${genome} --version=${version} --parameters=${parameters} --annotation=${annotation} --public=${public} --restrictionenzyme={enzyme}" 

# Run the command :
${CompareShell} --analysis=${analysis} --path=${path} --sample1=${sample1} --sample2=${sample2} --sample3=${sample3} --directories=${sample1Directories},${sample2Directories},${sample3Directories} --name=${name} --genome=${genome} --version=${version} --parameters=${parameters} --annotation=${annotation} --public=${public} --restrictionenzyme={enzyme}

echo "All done !"
echo


