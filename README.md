# [CaptureCompare](https://www.biorxiv.org/content/10.1101/2020.02.17.952572v1)

(C) Damien J Downes 14 May 2018: damien.downes@ndcls.ox.ac.uk


These package of scripts perform analysis on the replicates of Capture-C that form an experiment. 

The wrapper script enables the comparison of triplicates for two or three samples (cell types, growth conditions, timepoints, genetic models). Analysis includes library quality reporting, normalisation, mean and stdev calculation, sample comparison, DESeq2 analysis, windowing and plotting, data preparation for interaction calling with [peaky](https://github.com/cqgd/pky), and file preparation for data exploration with [CaptureSee](https://capturesee.molbiol.ox.ac.uk/).

CaptureCompare can be run locally or on a queued server.
         
## Requirements for input files
         
1. Input directories (three for each samples) from [CCseqBasic](https://github.com/Hughes-Genome-Group/CCseqBasicS) to be in this following structure:

         └── Directory
             ├── Test_A
             |   └── F6_greenGraphs_combined_Test_A_CCversion
             |       └── COMBINED_CCversion_VIEWPOINT.gff
             ├── Test_B
             |   └── F6_greenGraphs_combined_Test_B_CCversion
             |       └── COMBINED_CCversion_VIEWPOINT.gff      
             └── Test_C
                 └── F6_greenGraphs_combined_Test_C_CCversion
                     └── COMBINED_CCversion_VIEWPOINT.gff 
  
         Run name must match exactly the directory name it was run in (e.g. "Test_A" above)
  
2. A parameters file sepcifrying viewpoint name, starts and stops of viewpoint, exclusion and plotting regions, bin size, and window size.

3.  A run shell specificying the input options. For example see "compare.sh"

## Input Options

- **analysis:** Choice of 2way or 3way depending on number of samples.
- **path:** Directory containing 6/9 run files with structure described above.
- **samples1,2,3:** Name of samples, in same order as directories for samples.
- **directories:** List of 3 replicates for each sample in the correct sample order.
- **name:** Name for the analysis run: e.g. "Promoter"
- **genome:** Genome: hg19, mm9, or mm10
- **version:** CCanalyzer version (Any with F6_greenGraphs_combined_Test_A_CC4 format)
- **parameters:** Path to file containing windowing parameters - Viewpoint    Chr Frag_start  Frag_stop Exlusion_Start Exlusion_Stop Plot_Region_Start Plot_Region_Stop Bin_Size Window_size
- **public:** Destination for an output hub that can be loaded into CaptureSee.
- **enzyme:** Choice of enzyme used (dpnII, nalIII, hindIII)

## Outputs

![Human alpha-globin profile](http://sara.molbiol.ox.ac.uk/public/hugheslab/CaptureCompendium/data/HbaCombined_plot.png)

Two structured directories are generated: 

**Analyzed Data**
The first directory is generated where the script is run and has the output files including: library quality reports, bedgraphs, bigwigs, PDFs, R_scripts, DESe2 analysis, peaky input files.

These files will be organised in the following structure:

         └── Compendium_cis_analysis
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

**Public hub**
The second directory is generated in the location specified by **public**. This should be an external facing server for access by UCSC and CaptureSee. The files containing normalised means, subtractions plots, DESeq2 raw output, DESeq2 adjusted pvalues, and unionbedgraphs of normalised tracks are symbolically linked to the analysis directory. Additional configuration files are generated to allow for immediate loading into the browser of choice.

These files will be organised in the following structure:

         └── Public_hub
             ├── hub.txt
             ├── genomes.txt
             ├── Used_viewpoints.txt
             ├── Sample_order.txt
             ├── Test_A_cisReport.txt
             ├── Test_B_cisReport.txt
             ├── Test_C_cisReport.txt
             └── hg19
                 ├── deseq_output
                 ├── means
                 ├── pvalues
                 ├── subtractions
                 ├── tracks.txt
                 └── unionbedgraphs_normalised


 An examples hub can be found here: http://sara.molbiol.ox.ac.uk/public/hugheslab/CaptureCompendium/CapCompare_Example/hub.txt
 

## DESeq2 analysis
**NOTE:** The DESeq2 analysis performed is very rudimentary and results should be closely examined. Fragments are only tested for significance when they are on the same chromosome as the viewpoint (cis) and have 10 or more reporters across all samples. Adjusted pvalues are used for hub generation. To alter these parameters you will need to adjust the cis3way_DEseq2Scripter.pl file.

## Software Requirements
         - Perl
         - bedtools (v2.25.0)
         - ucsctools (v1.0)
                  - Example chromosome sizes provided in annotations
         - DESeq2 (running in R3.2)
         


