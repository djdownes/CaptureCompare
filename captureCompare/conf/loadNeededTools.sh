#!/bin/bash

#########################################################################################
#                                                                                       #
# Fill the below, to match your run environment                                         # 
#                                                                                       #
# The file works just like the loadNeededTools.sh file of your CCseqBasic installation  #
# ( CaptureCompare needs different tools available than CCseqBasic,                     #
#   so you cannot just copy the loadNeededTools.sh from your CCseqBasic installation )  #
#                                                                                       #
# Copyright 2018, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)                        #
#                                                                                       #
#########################################################################################

# #############################################################################

# This is the CONFIGURATION FILE to load in the needed toolkits ( conf/loadNeededTools.sh )

# #############################################################################

# Setting the needed programs to path.

# This can be done EITHER via module system, or via EXPORTING them to the path.
# If exporting to the path - the script does not check already existing conflicting programs (which may contain executable with same names as these)

# If neither useModuleSystem or setPathsHere : the script assumes all toolkits are already in path !

# If you are using module system          
useModuleSystem=1
# useModuleSystem=1 : load via module system
# useModuleSystem=0 : don't use module system   

# If you are adding to path (using the script below)
setPathsHere=0
# setPathsHere=1 : set tools to path using the bottom of this script
# setPathsHere=0 : dset tools to path using the bottom of this script

# If neither useModuleSystem or setPathsHere : the script assumes all toolkits are already in path !

# #############################################################################


setPathsForPipe(){

# #############################################################################

# PATHS_LOADED_VIA_MODULES

if [ "${useModuleSystem}" -eq 1 ]; then

module purge
# Removing all already-loaded modules to start from clean table

module load bedtools/2.25.0
# Supports bedtools versions 2.1* and 2.2*

module load perl/5.18.1
# Most probably will run with any perl

module load R/3.5.0-newgcc
# The beginning of the code runs in R 3.4.1(or newer)
# The deSeq2 part runs in R 3.2 or older - see below subroutine 'changeRfrom3_4to3_2()' 

# R libraries ( DESeq2 , tidyverse, cowplot, RcolorBrewer )
# test their existence by running the tester script testEnvironment.sh

# module load java/8u112
# The R libraries used here shouldn't use Java, but
# if they actually DO use Java, you should load Java here.

module list

# #############################################################################

# EXPORT_PATHS_IN_THIS_SCRIPT

elif [ "${setPathsHere}" -eq 1 ]; then

echo
echo "Adding tools to PATH .."
echo
    
# Note !!!!!
# - the script does not check already existing conflicting programs within $PATH (which may contain executable with same names as these)

export PATH=$PATH:/package/bedtools/2.25.0
export PATH=$PATH:/package/perl/5.18.1/bin
export PATH=$PATH:/package/R/3.5.0-newgcc/bin/R

# export PATH=$PATH:/package/java/8u121/bin/java
#
# The R libraries used here shouldn't use Java, but
# if they actually DO use Java, you should load Java here.


# See notes of SUPPORTED VERSIONS above !

echo $PATH

# #############################################################################

# EXPORT_NOTHING_i.e._ASSUMING_USER_HAS_TOOLS_LOADED_VIA_OTHER_MEANS

else
    
echo
echo "Tools should already be available in PATH - not loading anything .."
echo

fi

# #########################################

# UCSCtools are taken from install directory, in any case :

export PATH=$PATH:/${confFolder}/ucsctools



}

changeRfrom3_4to3_2(){

# #############################################################################

# PATHS_LOADED_VIA_MODULES

if [ "${useModuleSystem}" -eq 1 ]; then

module unload R

module load R/3.2.1
# The beginning of the code runs in R 3.5.0(or newer)
# The deSeq2 part runs in R 3.2.1 or older - loading that here

module list

# #############################################################################

# EXPORT_PATHS_IN_THIS_SCRIPT

elif [ "${setPathsHere}" -eq 1 ]; then

oldpath=$(echo ${PATH})
oldRpath='/package/R/3.4.1-newgcc/bin/R'

replaceThis=$(echo ${oldRpath} | sed 's/\//\\\//g')

newPATH=$(echo ${oldpath} | sed 's/'${replaceThis}'//')

export PATH=${newPATH}:/package/R/3.2.1/bin/R

echo $PATH

else

echo
echo "WARNING : We will need R 3.2 or older here - probably going to crash in DESeq2 (edit your config file 'loadNeededTools.sh' to take care of this)"
echo

R --version

fi

}
