#!/bin/bash

##########################################################################
# Copyright 2017, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
##########################################################################

setGenomeFasta(){
    
GenomeFasta="UNDETERMINED"

#-----------Genome-sizes-for-bowtie-commands----------------------------------------------  

# echo "_${genome}_"
    
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do
    
# echo ${supportedGenomes[$g]}

if [ "${supportedGenomes[$g]}" == "${genome}" ]; then
    GenomeFasta="${WholeGenomeFASTA[$g]}"
fi

done  

#------------------------------------------------

# Check that it got set ..

if [ "${GenomeFasta}" == "UNDETERMINED" ]; then 
  echo "Genome build " ${genome} " is not supported -- aborting !"  >&2
  exit 1 
fi    

# Check that the index file exists..

if [ ! -s "${GenomeFasta}" ]; then

  echo "Whole genome fasta for ${genome} : file not found : ${GenomeFasta} - aborting !"  >&2
  exit 1     
fi

echo
echo "Genome ${genome} .  Set whole genome fasta file : ${GenomeFasta}"


}


setUCSCgenomeSizes(){
    
genomesSizes="UNDETERMINED"
    
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do
    
# echo ${supportedGenomes[$g]}

if [ "${supportedGenomes[$g]}" == "${genome}" ]; then
    genomesSizes="${UCSC[$g]}"
fi

done 
    
if [ "${genomesSizes}" == "UNDETERMINED" ]; then 
  echo "Genome build " ${genome} " is not supported --- aborting !"  >&2
  exit 1 
fi

# Check that the file exists..
if [ ! -e "${genomesSizes}" ] || [ ! -r "${genomesSizes}" ] || [ ! -s "${genomesSizes}" ]; then
  echo "Genome build ${genome} file ${genomesSizes} not found or empty file - aborting !"  >&2
  exit 1     
fi

echo
echo "Genome ${genome} . Set UCSC genome sizes file : ${genomesSizes}"
echo

}



