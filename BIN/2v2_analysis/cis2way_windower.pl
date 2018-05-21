#!/usr/bin/perl
use strict;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long;

# This script is for bining and windowing capture C data. Requires normalised unionised files for a single viewpoint from
# 2 different samples/tissues. Single imput parameter file containing exclusion regions, visualisation region, and bin/window sizes.
# Output is a file of parameters for each viewpoint, and tab delimited multibedgraph of bins and windows

# Script adapted from Lar's manual scripts to be applicapble to multiple loci and more user friendly.
### (C) Damien Downes 16th May 2018.


&GetOptions
(
    "viewpoints=s"=>\ my $viewPoints,     # -viewpoints       VIEWPOINT	CHR VP_START VP_STOP EXCLSTART EXCLSTOP REGIONSTART REGIONSTOP BINSIZE WINDOWSIZE
	"samples=s"=> \ my $samples,		  # --samples		  Sample1,Sample2,Sample3
);


my ($sampleA, $sampleB) = split /\,/, $samples;

#########################################################
#### 1. Generate a hash of all the exclusion regions ####
#########################################################

my $Exclu_counter;
my %ExclusionHash;
my $excl_bin_start;
my $excl_bin_stop;

my $hba1_ex_start;
my $hba1_ex_stop;
my $hba2_ex_start;
my $hba2_ex_stop;
my $hbb1_ex_start;
my $hbb1_ex_stop;
my $hbb2_ex_start;
my $hbb2_ex_stop;

open (VIEWPOINTS, $viewPoints) or die "Cannot open viewpoint list\n";
while (my $viewpoint = <VIEWPOINTS>)
	{
		chomp($viewpoint);
		my ($viewID, $view_chr, $vp_start, $vp_stop, $excl_start, $excl_stop, $region_start, $region_stop, $bin_size, $window_size) = split(' ', $viewpoint);
		$Exclu_counter ++;
		$ExclusionHash{$Exclu_counter}{"Excl_Bin_Chr"} = $view_chr;
		$ExclusionHash{$Exclu_counter}{"Excl_Bin_Start"} = $excl_start;
		$ExclusionHash{$Exclu_counter}{"Excl_Bin_Stop"} = $excl_stop;
		$ExclusionHash{$Exclu_counter}{"Excl_View_ID"} = $viewID;
		$ExclusionHash{$Exclu_counter}{"Excl_VP_Start"} = $vp_start;
		$ExclusionHash{$Exclu_counter}{"Excl_VP_Stop"} = $vp_stop;
		### Store values for HbaCombined and HbbCombined bin exclusion
		if ($viewID =~ /Hba-1/)
			{
				$hba1_ex_start = $excl_start;
				$hba1_ex_stop = $excl_stop;
			}
		elsif ($viewID =~ /Hba-2/)
			{
				$hba2_ex_start = $excl_start;
				$hba2_ex_stop = $excl_stop;
			}
		elsif ($viewID =~ /Hbb-b1/)
			{
				$hbb1_ex_start = $excl_start;
				$hbb1_ex_stop = $excl_stop;	
			}
		elsif ($viewID =~ /Hbb-b2/)
			{
				$hbb2_ex_start = $excl_start;
				$hbb2_ex_stop = $excl_stop;
			}
	}
	
close VIEWPOINTS;

###################################
#### 2. Analyse each viewpoint ####
###################################

open (VIEWPOINTS, $viewPoints) or die "Cannot open viewpoint list\n";
while (my $viewpoint = <VIEWPOINTS>)
	{
		chomp($viewpoint);
		my ($viewID, $view_chr, $vp_start, $vp_stop, $excl_start, $excl_stop, $region_start, $region_stop, $bin_size, $window_size) = split(' ', $viewpoint);
		if ($bin_size < 1) {$bin_size = 250}
		if ($window_size < 1) {$window_size = 5000}
		
		my $parameters = "$viewID\_parameters.txt";
		my $output_bin = "$viewID\_bin.tab";
		my $output_window = "$viewID\_window.tab";
		
		unless (open(OUTFH, ">$output_bin")){die "Cannot open file $output_bin $!\n"; exit};
		unless (open(OUTFH2, ">$output_window")){die "Cannot open file $output_window $!\n"; exit};
		
		unless (open(PARAMETERS, ">$parameters")){die "Cannot open file $parameters $!\n"; exit};
		print  OUTFH "BinNum\tChr\tStart\tStop\t$sampleA\_rep1\t$sampleA\_rep2\t$sampleA\_rep3\t$sampleB\_rep1\t$sampleB\_rep2\t$sampleB\_rep3\n";
		print  OUTFH2 "BinNum\tChr\tStart\tStop\t$sampleA\_rep1\t$sampleA\_rep2\t$sampleA\_rep3\t$sampleB\_rep1\t$sampleB\_rep2\t$sampleB\_rep3\n";
	
	
		print  PARAMETERS "View ID: $viewID\n";
		print  PARAMETERS "Viewpoint: $view_chr\:$vp_start\-$vp_stop\n";	
		print  PARAMETERS "Exclusion: $view_chr\:$excl_start\-$excl_stop\n";
		print  PARAMETERS "Plot Region: $view_chr\:$region_start\-$region_stop\n";
		print  PARAMETERS "BinSize: $bin_size\n";
		print  PARAMETERS "Window_Size: $window_size\n";
		print  PARAMETERS "Sample A: $sampleA\n";
		print  PARAMETERS "Sample B: $sampleB\n";
		
		
		
	#	2.1 For plotted region we first need a hash of bins
	#		- The purpose of bins is to make windowing easier.
	#		- Bins overlaping 2 fragments are scored proportionally to the relative percent of each fragments
	
		
		my %binHash;
		my $BINnumber;
		my $binstop;
		my $binstart = $region_start;
			 
		while ($binstop < $region_stop)
			{
				$BINnumber++;
				$binstop = $binstart + ($bin_size-1);
				$binHash{$BINnumber}{"Chr"}= $view_chr;
				$binHash{$BINnumber}{"Start"}= $binstart;
				$binHash{$BINnumber}{"Stop"}= $binstop;
				$binstart=$binstart+$bin_size;
			}
		my $totalBins = $BINnumber;
		
		print  PARAMETERS "Total Bin number: $totalBins\n";

	#	2.2 Open the appropriate unionbedgraph should be "Viewpoint.unionbdg"
	#		- Chr Start Stop SampleA_rep1	SampleA_rep2	SampleA_rep3	SampleB_rep1	SampleB_rep2	SampleB_rep3
		
		my $unionbdg = "$viewID\.unionbdg";
		open(UNIONBDG, "$unionbdg") or die "Cannot open file $unionbdg\n";	
		while (my $line = <UNIONBDG>)
			{
				chomp($line);
				my ($chr, $frag_start, $frag_stop, $sampleA_1, $sampleA_2, $sampleA_3, $sampleB_1, $sampleB_2, $sampleB_3) = split(/\t/, $line);
				my $normregion;
				my $normfactor;
				my $work_bin_end;
				my $work_bin_start = $region_start;
				my $next_bin_start;
				$BINnumber = 0;                
				if($chr =~ /$view_chr/)
				    {
						if ($frag_stop < $region_start) {next;}
						if ($frag_start > $region_stop) {next;}
						while ($work_bin_end < $region_stop)
						{
							 my $frag_size = ($frag_stop-$frag_start);
							 #print  PARAMETERS "Chr:$chr\tFrag_Start: $frag_start\tFrag_Stop: $frag_stop\tFrag Size: $frag_size\t";
							 
							 $BINnumber++;
							 $work_bin_end = $work_bin_start + ($bin_size-1);
							 $next_bin_start = ($work_bin_start + $bin_size);
							 
							 #print  PARAMETERS "Bin Start: $work_bin_start Bin Stop: $work_bin_end\t";
							 
							 # Fragments starting before the bin and ending within
							 if($frag_start<$work_bin_start && $frag_stop>$work_bin_start && $frag_stop<=$work_bin_end)
								{
									 $normregion = ($frag_stop-$work_bin_start);
									 $normfactor = ($normregion / $bin_size);
									 #print  PARAMETERS "Bin: $BINnumber Norm factor 1: $normfactor\t";
									 $binHash{$BINnumber}{"$sampleA\_rep1_counts"}+=($normfactor*$sampleA_1);
									 $binHash{$BINnumber}{"$sampleA\_rep2_counts"}+=($normfactor*$sampleA_2);
									 $binHash{$BINnumber}{"$sampleA\_rep3_counts"}+=($normfactor*$sampleA_3);
									 $binHash{$BINnumber}{"$sampleB\_rep1_counts"}+=($normfactor*$sampleB_1);
									 $binHash{$BINnumber}{"$sampleB\_rep2_counts"}+=($normfactor*$sampleB_2);
									 $binHash{$BINnumber}{"$sampleB\_rep3_counts"}+=($normfactor*$sampleB_3);
								 }
							 
							 # Fragments within bin
							 if($frag_start>=$work_bin_start && $frag_stop<=$work_bin_end)
								 {
									 $normregion = $frag_stop - $frag_start;
									 $normfactor = $normregion / $bin_size;
									 #print  PARAMETERS "Bin: $BINnumber Norm factor 2: $normfactor\t";
									 $binHash{$BINnumber}{"$sampleA\_rep1_counts"}+=($normfactor*$sampleA_1);
									 $binHash{$BINnumber}{"$sampleA\_rep2_counts"}+=($normfactor*$sampleA_2);
									 $binHash{$BINnumber}{"$sampleA\_rep3_counts"}+=($normfactor*$sampleA_3);
									 $binHash{$BINnumber}{"$sampleB\_rep1_counts"}+=($normfactor*$sampleB_1);
									 $binHash{$BINnumber}{"$sampleB\_rep2_counts"}+=($normfactor*$sampleB_2);
									 $binHash{$BINnumber}{"$sampleB\_rep3_counts"}+=($normfactor*$sampleB_3);
								}
							 # Fragment starts in bin and goes into next bin	 
							 if($frag_start>=$work_bin_start && $frag_start<=$work_bin_end && $frag_stop>$work_bin_end)
								{
									 $normregion = $next_bin_start - $frag_start;
									 $normfactor = $normregion / $bin_size;
									 #print  PARAMETERS "Bin: $BINnumber Norm factor 3: $normfactor\n";
									 $binHash{$BINnumber}{"$sampleA\_rep1_counts"}+=($normfactor*$sampleA_1);
									 $binHash{$BINnumber}{"$sampleA\_rep2_counts"}+=($normfactor*$sampleA_2);
									 $binHash{$BINnumber}{"$sampleA\_rep3_counts"}+=($normfactor*$sampleA_3);
									 $binHash{$BINnumber}{"$sampleB\_rep1_counts"}+=($normfactor*$sampleB_1);
									 $binHash{$BINnumber}{"$sampleB\_rep2_counts"}+=($normfactor*$sampleB_2);
									 $binHash{$BINnumber}{"$sampleB\_rep3_counts"}+=($normfactor*$sampleB_3);
								}
							 #Fragment spans bin	 
							 if($frag_start<$work_bin_start && $frag_stop>$work_bin_end)
								{
									 #print  PARAMETERS "Bin: $BINnumber Norm factor 4: 1\t";
									 $binHash{$BINnumber}{"$sampleA\_rep1_counts"}+=($sampleA_1);
									 $binHash{$BINnumber}{"$sampleA\_rep2_counts"}+=($sampleA_2);
									 $binHash{$BINnumber}{"$sampleA\_rep3_counts"}+=($sampleA_3);
									 $binHash{$BINnumber}{"$sampleB\_rep1_counts"}+=($sampleB_1);
									 $binHash{$BINnumber}{"$sampleB\_rep2_counts"}+=($sampleB_2);
									 $binHash{$BINnumber}{"$sampleB\_rep3_counts"}+=($sampleB_3);
								}
							 #print  PARAMETERS "\n";
							 $work_bin_start=$next_bin_start;
						}
				    } else{next;}
			}
		
	#    2.3 Remove all reads that overlap with exclusion 
	#		- If HbaCombined or HbbCombined bins from both duplicated genes are excluded.
	
		foreach my $number1 ( sort { $a <=> $b } keys %binHash)
			{
				my $Binchr	 = $binHash{$number1}{"Chr"};
				my $Binstart = $binHash{$number1}{"Start"};
				my $Binstop  = $binHash{$number1}{"Stop"};
				
				foreach my $number2 ( sort { $a <=> $b } keys %ExclusionHash)
					{
						
						my $Excl_chr  = $ExclusionHash{$number2}{"Excl_Bin_Chr"};
						my $Excl_start = $ExclusionHash{$number2}{"Excl_Bin_Start"};
						my $Excl_stop  = $ExclusionHash{$number2}{"Excl_Bin_Stop"};
						my $Excl_vp_ID = $ExclusionHash{$number2}{"Excl_View_ID"};
						my $Excl_vp_start = $ExclusionHash{$number2}{"Excl_View_Start"};
						my $Excl_vp_stop = $ExclusionHash{$number2}{"Excl_View_Stop"};


						if ($Binchr =~ /$Excl_chr/)
							{
								if (($viewID =~ /HbaCombined/) or ($viewID =~ /Hba-1/) or ($viewID =~ /Hba-2/))		### Remove both Hba-1 and Hba-2 exclusions
									{
										if($Binstart==$hba1_ex_start or $Binstart==$hba2_ex_start)
											{
												delete $binHash{$number1};
											}
										elsif(($Binstop>$hba1_ex_start && $Binstop<$hba1_ex_stop) or ($Binstop>$hba2_ex_start && $Binstop<$hba2_ex_stop))
											{
												delete $binHash{$number1};
											}
										elsif(($Binstart>$hba1_ex_start && $Binstart<$hba1_ex_stop) or ($Binstart>$hba1_ex_start && $Binstart<$hba1_ex_stop))
											{
												delete $binHash{$number1};
											}
									}
								elsif (($viewID =~ /HbbCombined/) or ($viewID =~ /Hbb-b1/) or ($viewID =~ /Hbb-b2/))		### Remove both Hbb-b1 and Hbb-b2 exclusions
									{
										if($Binstart==$hbb1_ex_start or $Binstart==$hbb2_ex_start)
											{
												delete $binHash{$number1};
											}
										elsif(($Binstop>$hbb1_ex_start && $Binstop<$hbb1_ex_stop) or ($Binstop>$hbb2_ex_start && $Binstop<$hbb2_ex_stop))
											{
												delete $binHash{$number1};
											}
										elsif(($Binstart>$hbb1_ex_start && $Binstart<$hbb1_ex_stop) or ($Binstart>$hbb1_ex_start && $Binstart<$hbb1_ex_stop))
											{
												delete $binHash{$number1};
											}
									}
								elsif ($viewID =~ /$Excl_vp_ID/)		### Remove exclusion region around current viewpoint
									{
										if($Binstart==$Excl_start)
											{
												delete $binHash{$number1};
											}
										elsif($Binstop>$Excl_start && $Binstop<$Excl_stop)
											{
												delete $binHash{$number1};
											}
										elsif($Binstart>$Excl_start && $Binstart<$Excl_stop)
											{
												delete $binHash{$number1};
											}
									}
								else
									{
										if($Binstart==$Excl_vp_start)	### Remove bins overlapping other viewpoint fragments only
											{
												delete $binHash{$number1};
											}
										elsif($Binstop>$Excl_vp_start && $Binstop<$Excl_vp_stop)
											{
												delete $binHash{$number1};
											}
										elsif($Binstart>$Excl_vp_start && $Binstart<$Excl_vp_stop)
											{
												delete $binHash{$number1};
											}
									}	
							}
					}
			}

	# 2.4 Print the bins to a new file
			
		my $counter;	
		while ($counter < $totalBins)
			{
				$counter ++;
				if(exists $binHash{$counter})
					{
						my $chr = $binHash{$counter}{"Chr"};
						my $bin_start = $binHash{$counter}{"Start"};
						my $bin_stop = $binHash{$counter}{"Stop"};
						my $A_1 = $binHash{$counter}{"$sampleA\_rep1_counts"};
						my $A_2 = $binHash{$counter}{"$sampleA\_rep2_counts"};
						my $A_3 = $binHash{$counter}{"$sampleA\_rep3_counts"};
						my $B_1 = $binHash{$counter}{"$sampleB\_rep1_counts"};
						my $B_2 = $binHash{$counter}{"$sampleB\_rep2_counts"};
						my $B_3 = $binHash{$counter}{"$sampleB\_rep3_counts"};
						print OUTFH "$counter\t$chr\t$bin_start\t$bin_stop\t$A_1\t$A_2\t$A_3\t$B_1\t$B_2\t$B_3\n";
					}
			}


	#    2.5 Window data and print to the second output file. - not sure about Lar's math on the windowing.

		
		my $windowbins = sprintf("%d", ((($window_size/$bin_size)-1)/2));
		my $bins_contributing = 2*($windowbins)+1;
		
		my $minbin;
		my $maxbin;
		my $n;
		my $lastwinbin = ($totalBins-$windowbins);
		
		foreach my $current_bin ( sort { $a <=> $b } keys %binHash)
			{
				if ($current_bin>=$windowbins && $current_bin<=$lastwinbin)
					{
						$minbin = $current_bin-$windowbins;
						$maxbin = $current_bin+$windowbins;
						$n = $minbin;
						my $wA_1;
						my $wA_2;
						my $wA_3;
						my $wB_1;
						my $wB_2;
						my $wB_3;
						foreach $n ($minbin..$maxbin)
							{		
								$wA_1 += ($binHash{$n}{"$sampleA\_rep1_counts"}/$bins_contributing);
								$wA_2 += ($binHash{$n}{"$sampleA\_rep2_counts"}/$bins_contributing);
								$wA_3 += ($binHash{$n}{"$sampleA\_rep3_counts"}/$bins_contributing);
								$wB_1 += ($binHash{$n}{"$sampleB\_rep1_counts"}/$bins_contributing);
								$wB_2 += ($binHash{$n}{"$sampleB\_rep2_counts"}/$bins_contributing);
								$wB_3 += ($binHash{$n}{"$sampleB\_rep3_counts"}/$bins_contributing);
								$n++;
							}
						my $chr = $binHash{$current_bin}{"Chr"};						
						my $start = $binHash{$current_bin}{"Start"};
						my $stop = $binHash{$current_bin}{"Stop"};
						print OUTFH2 "$current_bin\t$chr\t$start\t$stop\t$wA_1\t$wA_2\t$wA_3\t$wB_1\t$wB_2\t$wB_3\n";
					}
				else{}
		}
		close  OUTFH;
		close  OUTFH2;
		close  PARAMETERS;
		close  UNIONBDG;
	}
close VIEWPOINTS;
exit;