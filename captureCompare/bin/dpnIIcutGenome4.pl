##########################################################################
# Copyright 2017, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
#                                                                        #
# This file is part of CCseqBasic5 .                                     #
#                                                                        #
# CCseqBasic5 is free software: you can redistribute it and/or modify    #
# it under the terms of the GNU General Public License as published by   #
# the Free Software Foundation, either version 3 of the License, or      #
# (at your option) any later version.                                    #
#                                                                        #
# CCseqBasic5 is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# GNU General Public License for more details.                           #
#                                                                        #
# You should have received a copy of the GNU General Public License      #
# along with CCseqBasic5.  If not, see <http://www.gnu.org/licenses/>.   #
##########################################################################

use strict;
# This version of the script outputs a file listing all of the dpnII sites in the genome in the format chr:start-stop
# The output is 1 based and it splits the dpnII fragments so that the GA is left on the end and the TC are at the start of the next fragment
# >2:1-3000018
# source of genome fasta files on Oxford CBRG server (eg for mm9): /databank/indices/bowtie/mm9/mm9.fa

# Opens the file and splits the filename from the path - this ouputs the file to the same path as the script
my $full_filename = $ARGV[0];
unless ($full_filename =~ /(.*)\.(fasta|fa)/) {die"filename does not match fasta/fa format"};
my $file_name=$1;
my $file_path="";
if ($file_name =~ /(.*\/)(\V++)/) {$file_path = $1; $file_name = $2};

my $output_filename = "genome_dpnII_coordinates.txt"; 

unless (open(OUTPUT, ">$output_filename")) {print "Cannot open file $output_filename\n"; exit;}

unless (open(FH, $full_filename)) {print "Cannot open file $full_filename\n"; exit;}

my $chr="undefined";
my %genomehash;
my $counter;

while (my $line= <FH>)
{

if ($line =~ />chr(.*)/)
    {
        $chr = $1; chomp $chr;
        next
    }
else
    {
        chomp $line;
        $genomehash{$chr}.=$line;  
    }
#$counter++; if ($counter>100000) {goto SPLIT}

}



SPLIT:

my @chrs = sort keys %genomehash;


foreach $chr(@chrs)
{
   
my @frags = split (/GATC/i,$genomehash{$chr});

# Deals with the first fragment
    my $start=1; my $end= $start + (length$frags[0])+1; 
    print OUTPUT "$chr:$start-$end\n";
    
# Deals with all the middle fragments
    for (my $i=1; $i<$#frags; $i++)
    {   
    $start = $end+1; $end = $start + (length $frags[$i]) +3;
    print OUTPUT "$chr:$start-$end\n";
    }

# Deals with the last fragment
    $start = $end+1; $end = $start + (length $frags[$#frags]) +1;
    print OUTPUT "$chr:$start-$end\n";
}

