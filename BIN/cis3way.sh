#!/bin/bash -l
#$ -cwd

###############################
###     Input Parameters    ###
###############################

echo
echo "Input parameters: $@"
echo

OPTS=`getopt -o g:: --long analysis:,path:,sample1:,sample2:,sample3:,directories:,name:,genome:,version:,parameters:,annotation:,public: --  "$@"`

eval set -- "$OPTS"

while true ; do
    case "$1" in
        --analysis) analysis=$2 ; shift 2 ;;
        --path) path=$2 ; shift 2 ;;
        --sample1) sample1=$2 ; shift 2 ;;
        --sample2) sample2=$2 ; shift 2 ;;
        --sample3) sample3=$2 ; shift 2 ;;
        --directories) directories=$2 ; shift 2 ;;
        --name) name=$2 ; shift 2 ;;
        -g|--genome) genome=$2 ; shift 2 ;;
        --version) version=$2 ; shift 2 ;;
        --parameters) parameters=$2 ; shift 2 ;;
        --annotation) annotation=$2 ; shift 2 ;;
        --public) public=$2 ; shift 2 ;;
        --) shift; break;;
    esac
done

echo
echo "Parsed parameters are..."
echo "Analysis Mode: ${analysis}"
echo "Path to input directories: ${path}"
echo "Sample1: ${sample1}"
echo "Sample2: ${sample2}"
if [ $sample3 != "" ]
    then
    echo "Sample3: ${sample3}"
    fi
echo "Directory list: ${directories}"
echo "Run name: ${name}"
echo "Genome: ${genome}"
echo "CC Version: ${version}"
echo "Path to view point parameters file: ${parameters}"
echo


#################################
###     Perl script paths     ###
#################################

### Full paths to the four perl run scripts.

normaliser="/path/to/scripts/eg/BIN/cis3way_nomaliser.pl"

union="/path/to/scripts/eg/BIN/cis3way_unionbdg.pl"

windower="/path/to/scripts/eg/BIN/cis3way_windower.pl"

plotScripter="/path/to/scripts/eg/BIN/cis3way_ggScripter.pl"

DEseq2Scripter="/path/to/scripts/eg/BIN/cis3way_DEseq2Scripter.pl"

DEseq2Parser="/path/to/scripts/eg/BIN/cis3way_DEseq2Parser.pl"

peakyPrep="/path/to/scripts/eg/BIN/cis3way_PeakYprep.pl"

#########################################
###     Directory of genome sizes     ###
#########################################

### Full paths to the directory containing chrom size files.

genomesSizes="/path/to/scripts/eg/annotation/${genome}.chrom.sizes"

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

echo "Now sorting normalised file:"
for file in *normalised.bdg

    do
    
    echo

    echo $file
    
    sortedname=$( echo $file | sed 's/.bdg//' ) 
    
    sort -k1,1 -k2,2n $file > ${sortedname}_sorted_TEMP.bedgraph

done

echo "Now sorting raw file:"
for file in *raw.bdg

    do
    
    echo

    echo $file
    
    sortedname=$( echo $file | sed 's/_raw.bdg//' ) 
    
    sort -k1,1 -k2,2n $file > ${sortedname}_sorted_TEMP_raw.bedgraph

done

###########################################################
###     Make union bedgraphs commands then run them     ###
###########################################################

echo
echo "Running bedtools union bedgraph for all oligos"
echo    
echo "Run command: perl ${union} -dir ${directories} -viewpoints ${parameters} -samples ${sample1},${sample2},${sample3}"
echo

perl ${union} -dir ${directories} -viewpoints ${parameters} -samples ${sample1},${sample2},${sample3}

module load bedtools

commands="bedtools_commands_TEMP.txt"

bash $commands

#############################################################
###     Generate a mean track and a subtraction track     ###
#############################################################

echo "Now doing maths for..."
for file in *normalised.unionbdg

    do

    oligoname=$( echo $file | sed 's/_normalised.unionbdg//' )
    echo "${oligoname}...Calculating means..."


    awk '{printf "%s\t%d\t%d\t%.4f\t%.4f\t%.4f\n", $1,$2,$3,(($4+$5+$6)/3),(($7+$8+$9)/3),(($10+$11+$12)/3)}' $file > "${oligoname}_TEMP_means.unionbdg"
    
    echo "...Separating..."
    
    cut -f 1,2,3,4  ${oligoname}_TEMP_means.unionbdg > ${oligoname}_${sample1}_mean.bdg
    cut -f 1,2,3,5  ${oligoname}_TEMP_means.unionbdg > ${oligoname}_${sample2}_mean.bdg

        
    if [ $analysis == "3way" ]
        then
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
    fi
    if [ $analysis == "2way" ]
        echo "...Subtracting..."        
        then
        awk '{printf "%s\t%d\t%d\t%.4f\t%.4f\n", $1,$2,$3,(($4+$5+$6)/3)-(($7+$8+$9)/3),(($7+$8+$9)/3)-(($4+$5+$6)/3)}' $file > "${oligoname}_TEMP_subs.unionbdg"
        cut -f 1,2,3,4  ${oligoname}_TEMP_subs.unionbdg > ${oligoname}_${sample1}_min_${sample2}.bdg
        cut -f 1,2,3,5  ${oligoname}_TEMP_subs.unionbdg > ${oligoname}_${sample2}_min_${sample1}.bdg
        echo "...done."
        echo
    fi
        
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

mkdir 3_tracks

mkdir 3_tracks/A_replicates_raw
rm -rf *raw.bdg
mv *raw.bw 3_tracks/A_replicates_raw/

mkdir 3_tracks/B_replicates_normalised
rm -rf *normalised.bdg
mv *normalised*bw 3_tracks/B_replicates_normalised

mkdir 3_tracks/C_means
rm -rf *mean.bdg
mv *_mean*bw 3_tracks/C_means/

mkdir 3_tracks/D_subtractions
rm -rf *_min_*bdg
mv *_min_*bw 3_tracks/D_subtractions/


#########################################
###    Windowing for each viewpoint   ###
#########################################

    echo "Preparing binned and windowed tab files for use in R"
    echo "Run command: perl ${windower} -viewpoints ${parameters} -samples ${sample1},${sample2},${sample3}"
    echo

    perl ${windower} -viewpoints ${parameters} -samples ${sample1},${sample2},${sample3}

#################################################
###    Generate Plotting R Scripts and run    ###
#################################################


    echo "Preparing R scripts for plotting"
    echo "Run command: perl ${plotScripter} -viewpoints ${parameters} -annotation ${annotation}"
    echo
    
    perl ${plotScripter} -viewpoints ${parameters} -annotation ${annotation}

    echo "Running plotting script for..."
    module load R/3.4.1-newgcc
    for file in *plotting.R
        do
        viewpoint=$( echo $file | sed 's/_plotting.R//' )
        echo "${viewpoint}"
    
        Rscript $file
        
         
    done
    module unload R/3.4.1-newgcc   

#########################
###     Tidy up 2     ###
#########################

mkdir 2_unionBedgraphs
mkdir 2_unionBedgraphs/B_normalised_counts
mv *normalised.unionbdg 2_unionBedgraphs/B_normalised_counts

mkdir 4_plotting

mkdir 4_plotting/A_parameters
mv *parameters.txt 4_plotting/A_parameters/

mkdir 4_plotting/B_binned
mv *bin.tab 4_plotting/B_binned/

mkdir 4_plotting/C_windowed
mv *window.tab 4_plotting/C_windowed/

mkdir 4_plotting/D_Rscripts
mv *.R 4_plotting/D_Rscripts/

mkdir 4_plotting/E_pdfs
mv *.pdf 4_plotting/E_pdfs/

##########################################
###     Make & Run DEseq2 Rscripts     ###
##########################################

    echo
    echo "Preparing R scripts for DEseq2"
    echo "Run command: perl ${DEseq2Scripter} --viewpoints ${parameters} -samples ${sample1},${sample2},${sample3} -name ${name}"
    echo
    
    perl ${DEseq2Scripter} --viewpoints ${parameters} -samples ${sample1},${sample2},${sample3} -name ${name}

    echo "Running DEseq2 script for..."
    module load R/3.2.1
    for file in *.R
        do
        viewpoint=$( echo $file | sed 's/_DESeq2.R//' )
        echo "${viewpoint}"
    
        Rscript $file
           
    done

    echo
    echo "RParsing padj for..."
    for file in *DESeq2_output.tab
        do
        analysis=$( echo $file | sed 's/_DESeq2_output.tab//' )
        echo "${analysis}"
    
        cut -f 1,7 $file > ${analysis}_TEMP_padj.tab
        
        perl ${DEseq2Parser}  --file ${analysis}_TEMP_padj.tab  --name ${analysis}
           
    done
    
    echo
    echo "Starting final conversion of..."
    for file in *.bdg
        do
    
        echo "$file"
    
        bigwigname=$( echo $file | sed 's/.bdg//' )
    
        sort -k1,1 -k2,2n $file > ${bigwigname}_TEMP_sorted.bdg
    
        echo
    
        bedGraphToBigWig ${bigwigname}_TEMP_sorted.bdg ${genomesSizes} ${bigwigname}.bw
    
    done
    
    echo
    echo "Removing all TEMP files"
    
    rm -rf *TEMP*    
    
#########################
###     Tidy up 3     ###
#########################

mkdir 5_DESeq2
mkdir 5_DESeq2/A_Rscripts
mv *_DESeq2.R 5_DESeq2/A_Rscripts/
mkdir 5_DESeq2/B_columnfile
mv *DESeq2.tsv 5_DESeq2/B_columnfile/
mkdir 5_DESeq2/C_inputMatricies
mv *DESeq2_in.tsv 5_DESeq2/C_inputMatricies/
mkdir 5_DESeq2/D_raw_output
mv *DESeq2_output.tab 5_DESeq2/D_raw_output/
mkdir 3_tracks/E_pvalues
rm -rf *logpadj.bdg
mv *.bw 3_tracks/E_pvalues/

#######################################
###     Prepare files for PeakY     ###             Script does nto wort yet. Fails to assigne correct Prey ID.
#######################################

echo
echo "Preparing raw counts for peakY"
echo "Run command: perl ${peakyPrep} --viewpoints ${parameters} --samples ${sample1},${sample2},${sample3} --name ${name} --genome ${genome}"
echo

perl ${peakyPrep} --viewpoints ${parameters} --samples ${sample1},${sample2},${sample3} --name ${name} --genome ${genome}

mkdir 2_unionBedgraphs/A_raw_counts
mv *raw.unionbdg 2_unionBedgraphs/A_raw_counts
mkdir 6_PeakyInputs
mv *tsv 6_PeakyInputs/
mv *key.bed 6_PeakyInputs/


###################################
###     A hub would be nice     ###
###################################


mkdir -p ${public}
rawrun="$(pwd)"

cd ${public}

echo  > hub.txt

	echo hub ${name} >> hub.txt
    echo shortLabel ${name} >> hub.txt
    echo longLabel ${name} CaptureCompare >> hub.txt
	echo genomesFile genomes.txt >> hub.txt
    echo email damien.downes@ndcls.ox.ac.uk >> hub.txt
    
echo > genomes.txt 

	echo genome ${genome} >> genomes.txt
    echo trackDb ${genome}/tracks.txt >> genomes.txt
 
### Make a parent track of all the means

echo  > tracks.txt

	echo track Means >> tracks.txt
	echo type bigWig >> tracks.txt
	echo container multiWig >> tracks.txt
	echo shortLabel Mean >> tracks.txt
	echo longLabel CC_Means >> tracks.txt
	echo visibility hide >> tracks.txt
	echo aggregate transparentOverlay >> tracks.txt
	echo showSubtrackColorOnUi on >> tracks.txt
	echo maxHeightPixels 500:100:0 >> tracks.txt
	echo priority 1 >> tracks.txt
	echo   >> tracks.txt
	echo   >> tracks.txt

mkdir -p ${genome}/means

ln -s ${rawrun}/3_tracks/C_means/*.bw .

for file in *.bw
do
    
    trackname=$( echo $file | sed 's/.bw//' )

    echo track "${trackname}" >> tracks.txt
    echo bigDataUrl http://userweb.molbiol.ox.ac.uk"${public}"/"${genome}"/means/"${file}" >> tracks.txt
    echo shortLabel "${trackname}" >> tracks.txt
    echo longLabel "${trackname}" >> tracks.txt
    echo type bigWig >> tracks.txt
    echo parent Means >> tracks.txt
    echo color 0,0,0 >> tracks.txt
    echo   >> tracks.txt


    sed -i 's/\.\///' tracks.txt

done

mv *.bw ${genome}/means/


### Make a parent track of all the subtractions

	echo   >> tracks.txt
	echo   >> tracks.txt
	echo track Subtractions >> tracks.txt
	echo type bigWig >> tracks.txt
	echo container multiWig >> tracks.txt
	echo shortLabel Subs >> tracks.txt
	echo longLabel CC_Subs >> tracks.txt
	echo visibility hide >> tracks.txt
	echo aggregate transparentOverlay >> tracks.txt
	echo showSubtrackColorOnUi on >> tracks.txt
	echo maxHeightPixels 500:100:0 >> tracks.txt
	echo priority 1 >> tracks.txt
	echo   >> tracks.txt
	echo   >> tracks.txt

mkdir -p ${genome}/subtractions

ln -s ${rawrun}/3_tracks/D_subtractions/*.bw .

for file in *.bw
do
    
    trackname=$( echo $file | sed 's/.bw//' )

    echo track "${trackname}" >> tracks.txt
    echo bigDataUrl http://userweb.molbiol.ox.ac.uk"${public}"/"${genome}"/subtractions/"${file}" >> tracks.txt
    echo shortLabel "${trackname}" >> tracks.txt
    echo longLabel "${trackname}" >> tracks.txt
    echo type bigWig >> tracks.txt
    echo parent Subtractions >> tracks.txt
    echo color 0,0,0 >> tracks.txt
    echo   >> tracks.txt


    sed -i 's/\.\///' tracks.txt

done

mv *.bw ${genome}/subtractions


### Make a parent track of all the pValues

	echo   >> tracks.txt
	echo   >> tracks.txt
	echo track pValues >> tracks.txt
	echo type bigWig >> tracks.txt
	echo container multiWig >> tracks.txt
	echo shortLabel pValues >> tracks.txt
	echo longLabel CC_pValues >> tracks.txt
	echo visibility hide >> tracks.txt
	echo aggregate transparentOverlay >> tracks.txt
	echo showSubtrackColorOnUi on >> tracks.txt
	echo maxHeightPixels 500:100:0 >> tracks.txt
	echo priority 1 >> tracks.txt
	echo   >> tracks.txt
	echo   >> tracks.txt

mkdir -p ${genome}/pvalues

ln -s ${rawrun}/3_tracks/E_pvalues/*.bw .

for file in *.bw
do
    
    trackname=$( echo $file | sed 's/.bw//' )

    echo track "${trackname}" >> tracks.txt
    echo bigDataUrl http://userweb.molbiol.ox.ac.uk"${public}"/"${genome}"/subtractions/"${file}" >> tracks.txt
    echo shortLabel "${trackname}" >> tracks.txt
    echo longLabel "${trackname}" >> tracks.txt
    echo type bigWig >> tracks.txt
    echo parent pValues >> tracks.txt
    echo color 0,0,0 >> tracks.txt
    echo   >> tracks.txt


    sed -i 's/\.\///' tracks.txt

done

mv *.bw ${genome}/pvalues

mv tracks.txt ${genome}

echo "Your hub is here:"
echo "http://userweb.molbiol.ox.ac.uk${public}/hub.txt"


echo
echo "All done!"
echo

exit
