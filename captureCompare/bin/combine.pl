#!/usr/bin/perl -w
use strict;
use Cwd;
use Data::Dumper;
use Getopt::Long;
use Try::Tiny;

&GetOptions
(
	"samples=s"=> \ my $samples,		  # --samples		  Sample1,Sample2,Sample3
);


my $output = "DpnII_processed.txt";
open(OUT, ">$output") or die "Can't open $output file";
open(INPUT, $samples) or die "Can't open $samples file";
while (my $line = <INPUT>)
        { 
        chomp $line;
        my ($chr, $start, $stop) = split(' ', $line);
        print OUT "$chr\:$start\-$stop\n"
        }
close OUT;
close INPUT;
        