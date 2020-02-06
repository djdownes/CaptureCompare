# CaptureCompare

(C) Damien J Downes 14 May 2018: damien.downes@ndcls.ox.ac.uk

These package of scripts perform analysis on a Capture-C replicates forming an experiment. 

The wrapper script enables the comparison of triplicates for two or three samples (cell types, growth conditions, timepoints, genetic models). Analysis includes library quality reporting, normalisation, mean and stdev calculation, sample comparison, DESeq2 analysis, windowing and plotting, data preparation for peak calling with [peaky](https://github.com/cqgd/pky), and file preparation for data exploration with [CaptureSee](https://capturesee.molbiol.ox.ac.uk/).

CaptureCompare can be run locally or on a queued server.
         
## Requirements for input files
         
1. Input directories from [CCseqBasic](https://github.com/Hughes-Genome-Group/CCseqBasicS) to be in this following structure:

         |--Directory
             |--Test_A
             |  `--F6_greenGraphs_combined_Test_A_CCversion
             |     `COMBINED_CCversion_VIEWPOINT.gff
             `--Test_B
                `--F6_greenGraphs_combined_Test_B_CCversion
                   `COMBINED_CCversion_VIEWPOINT.gff      
  
         Run name must match exactly the directory name it was run in (e.g. "Test_A" above)
  
2. A parameters file sepcifrying viewpoint name, starts and stops of viewpoint, exclusion and plotting regions, bin size, and window size

3.  A run shell specificying the input options. For example see "compare.sh"

## Input Options

- **path:** Directory containing 6/9 run files with structure described above.
- **samples1,2,3:** Name of samples, in same order as directories for samples.
- **directories:** List of 3 replicates for each sample in the correct sample order.
- **name:** Name for the analysis run: e.g. "Promoter"
- **genome:** Genome: hg19, mm9, or mm10
- **version:** CCanalyzer version (Any with F6_greenGraphs_combined_Test_A_CC4 format)
- **parameters:** Path to file containing windowing parameters - Viewpoint    Chr Frag_start  Frag_stop Exlusion_Start Exlusion_Stop Plot_Region_Start Plot_Region_Stop Bin_Size Window_size

## Outputs

Out files will be organised in the following structure:

         |--Compendium_cis_analysis
             ├── 1_reports
             ├── 2_unionBedgraphs
             │   ├── A_raw_counts
             │   └── B_normalised_counts
             ├── 3_tracks
             │   ├── A_replicates_raw
             │   ├── B_replicates_normalised
             │   ├── C_means
             │   ├── D_subtractions
             │   └── E_pvalues
             ├── 4_plotting
             │   ├── A_parameters
             │   ├── B_binned
             │   ├── C_windowed
             │   ├── D_Rscripts
             │   └── E_pdfs
             ├── 5_DESeq2
             │   ├── A_Rscripts
             │   ├── B_columnfile
             │   ├── C_inputMatricies
             │   └── D_raw_output
             └── 6_PeakyInputs

1. Reports for each sample with cis and trans interaction counts at each viewpoint
2. Union bedgraphs of raw and normalised read counds per fragment for all viewpoints 
3. Bigwigs for all viewpoints in each replicate, as well as the means for a sample     
4. Pdf of windowed viewpoints, and input files, and plotting scripts to facilitate easy re-analysis
5. DESe2 input and output files as well as R scripts for easy re-analysis
6. Formatted files for peak calling using peaky
         
 CaptureCompare also generates a public hub for loading into UCSC or CaptureSee

## Software Requirements
         - Perl
         - bedtools (v2.25.0)
         - ucsctools (v1.0)
                  - Example chromosome sizes provided in annotations
         - DEseq2 (running in R3.2)
         - 
         


