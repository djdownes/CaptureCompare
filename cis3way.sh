#!/bin/bash -l
#$ -cwd
#$ -M ddownes
#$ -m eas
#$ -j n
#$ -N emb3way

############################
###     Input Options    ###
############################

#       path            =   Directory containing 6/9 run files with structure described above.
#       samples1,2,3    =   Name of samples, in same order as directories for samples.
#       directories     =   List of 3 replicates for each sample in the correct sample order.
#       name            =   Name for the analysis run: e.g. "GWAS_Promoter"
#       genome          =   Genome: hg19,mm9,mm10
#       version         =   Supports .... (Any with F6_greenGraphs_combined_Test_A_CC4 format)
#       parameters      =   Path to file containing windowing parameters - Viewpoint    Chr Frag_start  Frag_stop Exlusion_Start Exlusion_Stop Plot_Region_Start Plot_Region_Stop Bin_Size Window_size


path="/t1-data/user/hugheslab/ddownes/Collaborations/Bee_Primative/beta_rerun/geneCapture"

sample1="mESC"              # Green

sample2="fetalLiver"        # Red

sample3="E10.5"             # Blue

directories="mESC_rep1,mESC_rep2,mESC_rep3,fetalLiver_rep1,fetalLiver_rep2,fetalLiver_rep3,E10.5_rep1,E10.5_rep2,E10.5_rep3"           # Must be in same order as samples!

name="Embryonic_wide"

genome="mm9"

version="CB4"

parameters="/t1-data/user/hugheslab/ddownes/Collaborations/Bee_Primative/beta_rerun/geneCapture/normalisation/wide_plotting.txt"

#################################
###     Perl script paths     ###
#################################

### Full paths to the four perl run scripts.

normaliser="/t1-data/user/hugheslab/ddownes/Scripts/gitHubScripts/cis3way/cis3way_nomaliser.pl"

union="/t1-data/user/hugheslab/ddownes/Scripts/gitHubScripts/cis3way/cis3way_unionbdg.pl"

windower="/t1-data/user/hugheslab/ddownes/Scripts/gitHubScripts/cis3way/cis3way_windower.pl"

plotScripter="/t1-data/user/hugheslab/ddownes/Scripts/gitHubScripts/cis3way/cis3way_ggScripter.pl"


#########################################
###     Directory of genome sizes     ###
#########################################

### Full paths to the directory containing chrom size files.

genomesSizes="/t1-data/user/hugheslab/ddownes/Scripts/gitHubScripts/cis2v2_3way_files/${genome}.chrom.sizes"

#########################################
###     Normalisation run command     ###
#########################################

echo
echo "Running normalisation for the CaptureC gff files"
echo
echo "Run command: perl ${normaliser} -path ${path} -dir ${directories} -viewpoints ${parameters} -name ${name} -version ${version}"
echo

perl ${normaliser} -path ${path} -dir ${directories} -viewpoints ${parameters} -name ${name} -version ${version}

####################################
###     Sorting of bedgraphs     ###
####################################

echo
echo "Moving into directory with bedgraphs"
echo

cd ${name}_cis_analysis

echo "Now working in:"
echo "$(pwd)"
echo "Generating sorted bedgraph files.."
echo

echo "Now sorting:"
for file in *.bdg

    do
    
    echo

    echo $file
    
    sortedname=$( echo $file | sed 's/.bdg//' ) 
    
    sort -k1,1 -k2,2n $file > ${sortedname}_sorted_TEMP.bedgraph

done

###########################################################
###     Make union bedgraphs commands then run them     ###
###########################################################

echo
echo "Running bedtools union bedgraph for all oligos"
echo    
echo "Run command: perl ${union} -dir ${directories} -viewpoints ${parameters}"
echo

perl ${union} -dir ${directories} -viewpoints ${parameters}

module load bedtools

commands="bedtools_commands_TEMP.txt"

bash $commands

#############################################################
###     Generate a mean track and a subtraction track     ###
#############################################################

echo "Now doing maths for..."
for file in *.unionbdg

    do

    oligoname=$( echo $file | sed 's/.unionbdg//' )            ### Files will be oligo.unionbdg
    echo "${oligoname}...Calculating means..."


    awk '{printf "%s\t%d\t%d\t%.4f\t%.4f\t%.4f\n", $1,$2,$3,(($4+$5+$6)/3),(($7+$8+$9)/3),(($10+$11+$12)/3)}' $file > "${oligoname}_TEMP_means.unionbdg"
    
    echo "...Separating..."
    
    cut -f 1,2,3,4  ${oligoname}_TEMP_means.unionbdg > ${oligoname}_${sample1}_mean.bdg
    cut -f 1,2,3,5  ${oligoname}_TEMP_means.unionbdg > ${oligoname}_${sample2}_mean.bdg
    cut -f 1,2,3,6  ${oligoname}_TEMP_means.unionbdg > ${oligoname}_${sample3}_mean.bdg
    
    echo "...Subtracting..."

    awk '{printf "%s\t%d\t%d\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n", $1,$2,$3,(($4+$5+$6)/3)-(($7+$8+$9)/3),(($7+$8+$9)/3)-(($4+$5+$6)/3),(($4+$5+$6)/3)-(($10+$11+$12)/3),(($10+$11+$12)/3)-(($4+$5+$6)/3),(($7+$8+$9)/3)-(($10+$11+$12)/3),(($10+$11+$12)/3)-(($7+$8+$9)/3)}' $file > "${oligoname}_TEMP_subs.unionbdg"


    cut -f 1,2,3,4  ${oligoname}_TEMP_subs.unionbdg > ${oligoname}_${sample1}_min_${sample2}.bdg
    cut -f 1,2,3,5  ${oligoname}_TEMP_subs.unionbdg > ${oligoname}_${sample2}_min_${sample1}.bdg
    cut -f 1,2,3,6  ${oligoname}_TEMP_subs.unionbdg > ${oligoname}_${sample1}_min_${sample3}.bdg
    cut -f 1,2,3,7  ${oligoname}_TEMP_subs.unionbdg > ${oligoname}_${sample3}_min_${sample1}.bdg
    cut -f 1,2,3,8  ${oligoname}_TEMP_subs.unionbdg > ${oligoname}_${sample2}_min_${sample3}.bdg
    cut -f 1,2,3,9  ${oligoname}_TEMP_subs.unionbdg > ${oligoname}_${sample3}_min_${sample2}.bdg
    echo "...done."
    echo
    
done

#################################################
###     Convert all bredgraphs to bigwigs     ###
#################################################

module load ucsctools

echo "Starting final conversion of..."
for file in *.bdg
    do


    echo "$file"

    bigwigname=$( echo $file | sed 's/.bdg//' )

    sort -k1,1 -k2,2n $file > ${bigwigname}_TEMP_sorted.bdg

    echo

    bedGraphToBigWig ${bigwigname}_TEMP_sorted.bdg ${genomesSizes} ${bigwigname}.bw

done

echo "Removing all TEMP files"

rm -rf *TEMP*

#########################
###     Tidy up 1     ###
#########################

mkdir 1_reports
mv *cisReport.txt* 1_reports/

mkdir 2_replicateTracks
rm -rf *normalised.bdg
mv *normalised*bw 2_replicateTracks

mkdir 4_meanTracks
rm -rf *mean.bdg
mv *_mean*bw 4_meanTracks/

mkdir 5_subTracks
rm -rf *_min_*bdg
mv *_min_*bw 5_subTracks/


#########################################
###    Windowing for each viewpoint   ###
#########################################

    echo "Preparing binned and windowed tab files for use in R"
    echo "Run command: perl ${windower} -viewpoints ${parameters} -samples ${sample1},${sample2},${sample3}"
    echo

    perl ${windower} -viewpoints ${parameters} -samples ${sample1},${sample2},${sample3}

#############################################
###    Could do the R stuff from here?    ### PERL SCRIPT TO MAKE R SCRIPTS, THEN RUN R USING VANILLA
#############################################


    echo "Preparing R scripts for plotting"
    echo "Run command: perl ${plotScripter} -viewpoints ${parameters} -genome ${genome}"
    echo
    
    perl ${plotScripter} -viewpoints ${parameters} -genome ${genome}

    echo "Running plotting script for..."
    module load R/3.4.1-newgcc
    for file in *plotting.R
        do
        viewpoint=$( echo $file | sed 's/_plotting.R//' )
        echo "${viewpoint}"
    
        Rscript $file
           
    done

#########################
###     Tidy up 2     ###
#########################

mkdir 3_unionBedgraphs
mv *.unionbdg 3_unionBedgraphs/

mkdir 6_windowFiles
mv *parameters.txt 6_windowFiles/
mv *window.tab 6_windowFiles/
mv *bin.tab 6_windowFiles/

mkdir 8_plots
mv *.pdf 8_plots/

mkdir 7_plotScripts
mv *.R 7_plotScripts/

###################################
###     A hub would be nice     ###
###################################


echo
echo "All done!"
echo

exit
