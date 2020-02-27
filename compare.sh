#!/bin/bash
#$ -cwd

############################
###     Input Options    ###
############################

# Choice of comparison (either "2way" or "3way")              
analysis="3way"

# Directory containing 6/9 run files with structure described in README.md.
path="/PATH/TO/DIRECTORY/WITH/ALL/RESULTS/"

# Desired output name of samples with the exact name of the respective input folders.
sample1="SAMPLE1"
sample1Directories="SAMP1_rep1,SAMP1_rep2,SAMP1_rep3"

sample2="SAMPLE2"
sample2Directories="SAMP2_rep1,SAMP2_rep2,SAMP2_rep3"

sample3="SAMPLE3"                                             #if running 2way leave "" blank
sample3Directories="SAMP3_rep1,SAMP3_rep2,SAMP3_rep3"             #if running 2way leave "" blank

# Name for the analysis run: e.g. "GWAS_Promoter"
name="FREEFORM_NAME"

# Genome (supports "hg18","hg19","mm9","mm10")
genome="GENOME"

# CaptureC analyser version (Supports any version with output strcuture: F6_greenGraphs_combined_Samples_Version format) e.g. "CS5"
version="VERSION"

# Path to file containing viewpoints and windowing parameters -
# Format: Viewpoint    Chr Frag_start  Frag_stop Exlusion_Start Exlusion_Stop Plot_Region_Start Plot_Region_Stop Bin_Size Window_size
parameters="/PATH/TO/PARAMETERS/FILE/Parameters.txt"

# Path to where you would like the public UCSC hub to be made
public="/PATH/TO/HUB/LOCATION"

# Name of enzyme used: supports, "dpnII", "nlaIII", "hindIII"
enzyme="ENZYME"

#====================================================#
### Core paths for files and scripts.
#====================================================#

#Path to cis3way shell.
CompareShell="/PATH/TO/CIS/3WAY/SHELL/cis3way.sh"

#Default annotation for plots is ref seq genes but any bed file can be inserted.
annotation="/PATH/TO/ANNOTATION/USED/FOR/PDF/RefSeqGenes_${genome}.bed"

#Path to folder containing digested genomes - will search here for correct digest and create if not present.
digest="/PATH/TO/SAVE/GENOME/DIGESTS/"

#====================================================#
### Run Analysis
#====================================================#

# We are now here
rundir=$( pwd )
echo "Running ${CompareShell} in ${rundir}"

# Print run command
echo "${CompareShell} --analysis=${analysis} --path=${path} --sample1=${sample1} --sample2=${sample2} --sample3=${sample3} --directories=${sample1Directories},${sample2Directories},${sample3Directories} --name=${name} --genome=${genome} --version=${version} --parameters=${parameters} --annotation=${annotation} --public=${public} --restrictionenzyme=${enzyme} --frags=${digest}" 

# Run the command :
${CompareShell} --analysis=${analysis} --path=${path} --sample1=${sample1} --sample2=${sample2} --sample3=${sample3} --directories=${sample1Directories},${sample2Directories},${sample3Directories} --name=${name} --genome=${genome} --version=${version} --parameters=${parameters} --annotation=${annotation} --public=${public} --restrictionenzyme=${enzyme} --frags=${digest}

echo "All done !"
echo


