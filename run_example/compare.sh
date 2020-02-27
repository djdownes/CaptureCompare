#!/bin/bash
#$ -cwd
#$ -M ddownes
#$ -m eas
#$ -j n
#$ -N test  



############################
###     Input Options    ###
############################

# Choice of comparison (either "2way" or "3way")              
analysis="3way"

# Directory containing 6/9 run files with structure described in README.md.
path="/public/hugheslab/CaptureCompendium/data/CapCompare"

# Desired output name of samples with the exact name of the respective input folders.
sample1="Erythroid"
sample1Directories="Ery_rep1,Ery_rep2,Ery_rep3"

sample2="hESC"
sample2Directories="hESC_rep1,hESC_rep2,hESC_rep3"

sample3="HUVEC"                                             #if running 2way leave "" blank
sample3Directories="HUVEC_rep1,HUVEC_rep2,HUVEC_rep3"             #if running 2way leave "" blank

# Name for the analysis run: e.g. "GWAS_Promoter"
name="CapCompare_Example"

# Genome (supports hg18,hg19,mm9,mm10)
genome="hg19"

# CaptureC analyser version (Supports any version with output strcuture: F6_greenGraphs_combined_Samples_Version format)
version="CB4"

# Path to file containing viewpoints and windowing parameters -
# Format: Viewpoint    Chr Frag_start  Frag_stop Exlusion_Start Exlusion_Stop Plot_Region_Start Plot_Region_Stop Bin_Size Window_size
parameters="/t1-data/user/hugheslab/ddownes/manuscript_hubs/CaptureCompare/Parameters.txt"

# Path to where you would like the public UCSC hub to be made
public="/public/hugheslab/CaptureCompendium/hub"

# Name of enzyme used: supports, dpnII, nlaIII, hindIII
enzyme="dpnII"

#====================================================#
### Core paths for files and scripts.
#====================================================#

#Path to cis3way shell.
CompareShell="/RELEASE/cis3way.sh"

#Default annotation for plots is ref seq genes but any bed file can be inserted.
annotation="/RELEASE/run_example/annotationExamples/RefSeqGenes_${genome}.bed"

#Path to folder containing digested genomes.
digest="/RELEASE/"

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


