#!/usr/bin/perl
use strict;
use Cwd;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long;


### (C) Damien Downes 16th May 2018.


&GetOptions
(
    "viewpoints=s"=>\ my $viewPoints,     # --viewpoints      VIEWPOINT	CHR VP_START VP_STOP EXCLSTART EXCLSTOP REGIONSTART REGIONSTOP BINSIZE WINDOWSIZE
	"samples=s"=> \ my $samples,		  # --samples		  Sample1,Sample2,Sample3
	"name=s" => \  my $run_name,		      # --name			  Experiment name
);

my ($sampleA, $sampleB, $sampleC) = split /\,/, $samples;
my $current_directory = cwd;

my $reporter_count;
##### Generate a single file describing samples

my $coldata = "$run_name\_DESeq2.tsv";
open (COLDATA, ">$coldata") or die "Cannot open file $coldata\n";

print COLDATA "\tcell\n";
print COLDATA "$sampleA\_rep1\t$sampleA\n";
print COLDATA "$sampleA\_rep2\t$sampleA\n";
print COLDATA "$sampleA\_rep3\t$sampleA\n";
print COLDATA "$sampleB\_rep1\t$sampleB\n";
print COLDATA "$sampleB\_rep2\t$sampleB\n";
print COLDATA "$sampleB\_rep3\t$sampleB\n";
if (length($sampleC) != 0)
    {
print COLDATA "$sampleC\_rep1\t$sampleC\n";
print COLDATA "$sampleC\_rep2\t$sampleC\n";
print COLDATA "$sampleC\_rep3\t$sampleC\n";
	}
close COLDATA;

open (VIEWPOINTS, $viewPoints) or die "Cannot open viewpoint list\n";
while (my $viewpoint = <VIEWPOINTS>)
	{
		chomp($viewpoint);
		my ($viewID,$vp_chr, @rest) = split(' ', $viewpoint);

#### Print R script - this bit needs work.
	
        open (OUTFH, ">$viewID\_DESeq2.R") or die "Cannot open file $viewID\_DESeq2.R\n\n";
		print OUTFH "# Set Working Directory and Load Libraries=====================================\n";		
        print OUTFH "setwd(\"$current_directory\")\n\n";		
		print OUTFH "library(\"DESeq2\")\n\n";

		print OUTFH "# Load Data –––––––––––––––––––================================================\n";
		print OUTFH "data.file <- read.table(\"$viewID\_DESeq2_in.tsv\")\n";		
		print OUTFH "colData <- read.table(\"$run_name\_DESeq2.tsv\",header=TRUE,row.names=1)\n\n";

		print OUTFH "# Run DEseq2 ==================================================================\n";		
		print OUTFH "dds <- DESeqDataSetFromMatrix(countData = data.file,colData = colData,design = ~ cell)\n";
		print OUTFH "dds <- DESeq(dds)\n\n";
		
#		res.A.B <- results(dds1, contrast=c("condition","treat","untreat"))		### Need to determine 2 or 3 samples for this section.
	
		print OUTFH "# Extract Results =============================================================\n";		
		print OUTFH "res<-results(dds)\n";
		print OUTFH "resAB <- results(dds,contrast=list(\"cell$sampleA\",\"cell$sampleB\"))\n";
		print OUTFH "write.table(resAB, file=\"$viewID\_$sampleA\_$sampleB\_DESeq2_output.tab\", sep=\"\\t\")\n";		
		if (length($sampleC) != 0)
			 {		
		print OUTFH "resAC <- results(dds,contrast=list(\"cell$sampleA\",\"cell$sampleC\"))\n";
		print OUTFH "resBC <- results(dds,contrast=list(\"cell$sampleB\",\"cell$sampleC\"))\n";
		print OUTFH "write.table(resAC, file=\"$viewID\_$sampleA\_$sampleC\_DESeq2_output.tab\", sep=\"\\t\")\n";			
		print OUTFH "write.table(resBC, file=\"$viewID\_$sampleB\_$sampleC\_DESeq2_output.tab\", sep=\"\\t\")\n";
			 }

        close OUTFH;
		
##### Generate a matrix for each of the viewpoints at same time as script
###				name1	name2	name3	name4
###		uid		count	count	count	count


		my $matrix = "$viewID\_raw.unionbdg";
        open(DEINPUT, ">$viewID\_DESeq2_in.tsv") or die "Cannot open file $viewID\_DESeq2_in.tsv\n\n";
		
		if (length($sampleC) != 0)
			{
				print DEINPUT "\t$sampleA\_rep1\t$sampleA\_rep2\t$sampleA\_rep3\t$sampleB\_rep1\t$sampleB\_rep2\t$sampleB\_rep3\t$sampleC\_rep1\t$sampleC\_rep2\t$sampleC\_rep3\n";		
				open(MATRIX, $matrix) or die "Cannot open file $matrix\n";
				while (my $raw_counts = <MATRIX>)
					{
						chomp $raw_counts;
						my ($chr, $start, $stop, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9) = split(' ', $raw_counts);
						if ($chr =~ /chrom/){next;}
						if ($chr ne $vp_chr){next;}									# Only do DESeq2 analysis on cis interacting fragments.
						$reporter_count= ($c1+$c2+$c3+$c4+$c5+$c6+$c7+$c8+$c9);
                        if ($reporter_count<10) {next;}								# Can adjust this value to increase or decrease the number of fragments tested.
						print DEINPUT "$chr:$start-$stop\t$c1\t$c2\t$c3\t$c4\t$c5\t$c6\t$c7\t$c8\t$c9\n";
					}
			}
		if (length($sampleC) == 0)
			{
				print DEINPUT "\t$sampleA\_rep1\t$sampleA\_rep2\t$sampleA\_rep3\t$sampleB\_rep1\t$sampleB\_rep2\t$sampleB\_rep3\n";		
				open(MATRIX, $matrix) or die "Cannot open file $matrix\n";
				while (my $raw_counts = <MATRIX>)
					{
						chomp $raw_counts;
						my ($chr, $start, $stop, $c1, $c2, $c3, $c4, $c5, $c6,) = split(' ', $raw_counts);
						if ($chr =~ /chrom/){next;}
						if ($chr ne $vp_chr){next;}
						$reporter_count= ($c1+$c2+$c3+$c4+$c5+$c6);
                        if ($reporter_count<10) {next;}
						print DEINPUT "$chr:$start-$stop\t$c1\t$c2\t$c3\t$c4\t$c5\t$c6\n";
					}
			}		
		
		close DEINPUT;
		close MATRIX;
	}

close VIEWPOINTS;
exit;
