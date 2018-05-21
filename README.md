# CaptureCompare

(C) Damien J Downes 14 May 2018: damien.downes@ndcls.ox.ac.uk

These scripts perform post processing of all gff files listed in an viewpoint file set of samples and controls from CC analysis software.

The appropriate shell script for the design (2 or 3 cell types) will call the normalisation, union bedgraph and plotting scripts. Normalisation is per 100,000 unique cis reads.

###
Requirements
###

1. Input options as described below added to the shell script lines 21-37

2. Output folder will be a subdirectory of the folder that the script is in run in

3. Input directories to be in this following structure: - Run name must match the directory name it was run in (e.g "Test_A")
         |--Directory
             |--Test_A
             |  `--F6_greenGraphs_combined_Test_A_version
             |     `COMBINED_version_VIEWPOINT.gff
             `--Test_B
                `--F6_greenGraphs_combined_Test_B_version
                   `COMBINED_version_VIEWPOINT.gff      
  
4. Windowing parameters file with viewpoint name, start and stop of viewpoint, exclusion and plotting regions, as well as the bin and window size (default 250,5000)

5. perl

6. bedtools v2.25.0

7. ucsctools v1.0
    - sub requirement: UCSC chromosome sizes - provided in "annotations"

8. R v3.4.1-newgcc


###     
Input Options
###

#       path            		=   Directory containing 6/9 run files with structure described above.
#       samples1,2,3    	=   Name of samples, in same order as directories for samples.
#       directories     		=   List of 3 replicates for each sample in the correct sample order.
#       name            		=   Name for the analysis run: e.g. "Promoter"
#       genome          		=   Genome: hg19, mm9, or mm10
#       version         		=   CCanalyzer version (Any with F6_greenGraphs_combined_Test_A_CC4 format)
#       parameters      		=   Path to file containing windowing parameters - Viewpoint    Chr Frag_start  Frag_stop Exlusion_Start Exlusion_Stop Plot_Region_Start Plot_Region_Stop Bin_Size Window_size


###
The output of this script is:
###

1 - Reports for each sample with cis and trans interaction counts at each viewpoint
2 - Normalised bigwigs for all viewpoints in each replicate
3 - Union bedgraphs of normalised read counds per fragment for all viewpoints
4 - Bigwigs of the normalised mean for three replicates
5 - Bigwigs of the subtracted mean for comparison samples
6 - Bin and windowed bin files for each viewpoint
7 - R scripts used to generate plots
8 - Pdf of windowed tracks in a given region with annotated genes