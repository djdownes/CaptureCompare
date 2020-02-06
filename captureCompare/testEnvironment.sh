#!/bin/bash

##########################################################################
# Copyright 2018, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
##########################################################################


function finish {
echo
echo
echo "###########################################"
echo
echo "Finished with tests !"
echo
echo "Check that you got no errors in above listings !"
echo
echo "###########################################"
echo
echo
}
trap finish EXIT

# Set the default return value
exitCode=0

echo
echo "This is test for CaptureCompare configuration setup ! "
echo
echo "( For automated testing : Return value of the script is '0' if all clear or only warnings, and '1' if fatal errors encountered. )"
echo
sleep 2
echo "Running test script $0"
echo
echo "###########################################"
echo
echo "1) Testing that the UNIX basic tools (sed, awk, etc) are found"
echo "2) Testing that the needed scripts are found 'near by' the main script "
echo "3) Setting the environment - running the conf/config.sh , to set the user-defined parameters"
echo "4) Listing the set allowed genomes"
echo "5) Testing that all toolkits (bedtools etc) are found in the user-defined locations"
echo "6) Testing that the user-defined public server exists"
echo
sleep 5

##########################################################################

echo "###########################################"
echo
echo "1) Testing that the UNIX basic tools (sed, awk, grep, et cetera) are found"
echo

echo "Calling sed .."
echo
sed --version | head -n 1
sed --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "Calling awk .."
echo
awk --version | head -n 1
awk --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "Calling grep .."
echo
grep --version | head -n 1
grep --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2


echo "Calling GNU coreutils .."
echo

date   --version | head -n 1
date   --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
ln     --version | head -n 1
ln     --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
ls     --version | head -n 1
ls     --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
mkdir  --version | head -n 1
mkdir  --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
mv     --version | head -n 1
mv     --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 4

echo "Calling 'which'  .."
echo
which --version | head -n 1
which --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

diffLoadFailed=0
echo "Calling 'diff' (optional - needed only in this tester script) .."
echo
diff --version | head -n 1
diff --version >> /dev/null
diffLoadFailed=$?
echo

sleep 2

echo "Calling 'hostname' (optional - it is only used to print out the name of the computer) .."
echo
hostname --version 2>&1 
echo

sleep 2

echo "Calling 'module' (optional - only needed if you set your  conf/loadNeededTools.sh   to use the module environment) .."
echo
module --version 2>&1 | head -n 2
echo

sleep 3


##########################################################################

# Test that the script files exist ..

echo "###########################################"
echo
echo "2) Testing that the needed scripts are found 'near by' the main script .."
echo

sleep 2

PipeTopPath="$( dirname $0 )"
dirname $0 >> /dev/null
exitCode=$(( ${exitCode} + $? ))

# From where to call the CONFIGURATION script..

confFolder="${PipeTopPath}/conf"
mainScriptFolder="${PipeTopPath}/bin"
helperScriptFolder="${PipeTopPath}/bin"

echo
echo "This is where they should be ( will soon see if they actually are there ) :"
echo
echo "PipeTopPath        ${PipeTopPath}"
echo "confFolder         ${confFolder}"
echo "mainScriptFolder   ${mainScriptFolder}"
echo "helperScriptFolder ${helperScriptFolder}"
echo

sleep 4


scriptFilesMissing=0

# Check that it can find the scripts .. ( not checking all - believing that if these exist, the rest exist too )

echo
echo "Master script and its tester script :"
echo
ls ${PipeTopPath}/cis3way.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${PipeTopPath}/testEnvironment.sh 
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3
echo "Main analysis scripts :"
echo
ls ${mainScriptFolder}/cis3way_DEseq2Parser.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${mainScriptFolder}/cis3way_DEseq2Scripter.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${mainScriptFolder}/cis3way_ggScripter.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${mainScriptFolder}/cis3way_nomaliser.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${mainScriptFolder}/cis3way_PeakYprep.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${mainScriptFolder}/cis3way_unionbdg.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${mainScriptFolder}/cis3way_windower.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${mainScriptFolder}/combine.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3
echo "In-silico cutter scripts - for each Restriction Enzyme :"
echo
ls ${mainScriptFolder}/dpnIIcutGenome4.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${mainScriptFolder}/nlaIIIcutGenome4.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
# ls ${mainScriptFolder}/hindIIIcutGenome4.pl
# scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo


echo "UCSC downloaded tools for visualisation (downloaded 06May2014 from http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/ ) :"
echo
ls ${confFolder}/ucsctools/fetchChromSizes
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${confFolder}/ucsctools/bedGraphToBigWig
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))

echo
sleep 3
echo "Helper subroutines :"
echo

ls ${helperScriptFolder}/helpersubs.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${helperScriptFolder}/inputoutputtesters.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${helperScriptFolder}/genomeSetters.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3

echo "Configuration setters :"
echo
ls ${confFolder}/genomeBuildSetup.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${confFolder}/loadNeededTools.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${confFolder}/serverAddressAndPublicDiskSetup.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3
echo "Configuration tester helpers :"
echo
ls ${helperScriptFolder}/validateSetup/g.txt
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${helperScriptFolder}/validateSetup/l.txt
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${helperScriptFolder}/validateSetup/s.txt
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3

if [ "${scriptFilesMissing}" -ne 0 ]
then
echo
echo "###########################################"
echo
echo "ERROR !   The scripts CaptureCompare is dependent on, are not found in their correct relative paths !"
echo "          Maybe your tar archive was corrupted, or you meddled with the folder structure after unpacking ?"
echo
echo "###########################################"
echo
echo "This is what you SHOULD see if you run 'tree' command in your CaptureCompare folder :"
echo
echo ' |-- cis3way.sh'
echo ' |-- testEnvironment.sh'
echo ' |'
echo ' `-- bin'
echo '     |-- cis3way_DEseq2Parser.pl cis3way_DEseq2Scripter.pl'
echo '     |-- cis3way_unionbdg.pl cis3way_nomaliser.pl'
echo '     |-- cis3way_PeakYprep.pl'
echo '     |-- cis3way_windower.pl cis3way_ggScripter.pl'
echo '     |-- combine.pl'
echo '     |-- genomeSetters.sh inputoutputtesters.sh helpersubs.sh'
echo '     `-- dpnIIcutGenome4.pl hindIIIcutGenome4.pl nlaIIIcutGenome4.pl'
echo ''

echo '`-- config'
echo '    |-- genomeBuildSetup.sh'
echo '    |-- loadNeededTools.sh'
echo '    |-- serverAddressAndPublicDiskSetup.sh'
echo '    |'
echo '    |-- ucsctools'
echo '    |   |-- bedGraphToBigWig '
echo '    |   `-- fetchChromSizes'
echo '    |'
echo '    |-- UCSCgenomeSizes'
echo '    |   |-- mm10/9.chrom.sizes'
echo '    |   `-- hg18/19.chrom.sizes '
echo '    |'
echo '    `-- annotationExamples'
echo '        |-- RefSeqGenes_hg18.bed'
echo '        |-- RefSeqGenes_hg19.bed'
echo '        `-- RefSeqGenes_mm9.bed'
echo ''

sleep 4

# Return the value : 0 if only warnings, 1 if fatal problems.
exit 1

fi

exitCode=$(( ${exitCode} + ${scriptFilesMissing} ))
sleep 5

##########################################################################

# Test that user has made at least SOME changes to them (otherwise they are running with the WIMM configuration .. )

echo
echo "###########################################"
echo
echo "3) Setting the environment - running the conf/(setupscripts).sh , to set the user-defined parameters"
echo

sleep 6


# We have 3 files - if all of them are in WIMM setup, we end up with "0" as the value in the end ..
setupMade=3
genomeSetupMade=1
toolsSetupMade=1
serverSetupMade=1

TEMPcount=$(($( diff ${helperScriptFolder}/validateSetup/g.txt ${confFolder}/genomeBuildSetup.sh | grep -c "" )))

if [ "${TEMPcount}" -eq 0 ]
then
setupMade=$((${setupMade}-1))
genomeSetupMade=0
echo
echo "WARNING ! It seems you haven't set up your Bowtie Genome indices !"
echo "          Add your Bowtie indices to this file : "
echo "          ${confFolder}/genomeBuildSetup.sh "
echo
sleep 6
fi

TEMPcount=$(($( diff ${helperScriptFolder}/validateSetup/l.txt ${confFolder}/loadNeededTools.sh | grep -c "" )))

if [ "${TEMPcount}" -eq 0 ]
then
setupMade=$((${setupMade}-1))
toolsSetupMade=0
echo
echo "WARNING ! It seems you haven't set up the loading of your Needed Toolkits !"
echo "          Add your toolkit paths to this file : "
echo "          ${confFolder}/loadNeededTools.sh "
echo
echo "NOTE !!   You need to edit this file ALSO if you want to disable loading the toolkits via the above script."
echo "          To disable the loading of the tools, set : setToolLocations=0 "
echo
sleep 8
fi

TEMPcount=$(($( diff ${helperScriptFolder}/validateSetup/s.txt ${confFolder}/serverAddressAndPublicDiskSetup.sh | grep -c "" )))

if [ "${TEMPcount}" -eq 0 ]
then
setupMade=$((${setupMade}-1))
serverSetupMade=0
echo
echo "WARNING ! It seems you haven't set up your Server address and Public Disk Area !"
echo "          Add your Server address to this file : "
echo "          ${confFolder}/serverAddressAndPublicDiskSetup.sh "
echo
sleep 4
fi

# Only continue to the rest of the script, if there is some changes in the above listings ..

if [ "${setupMade}" -eq 0 ]
then
echo 
echo
echo "Could not finish testing, as you hadn't set up your environment !"
echo
echo "Set up your files according to instructions in :"
echo "http://sara.molbiol.ox.ac.uk/public/telenius/CCseqBasicManual/instructionsGeneral.html"
echo
sleep 4

exitCode=1

fi

if [ "${exitCode}" -gt 0 ]
then
exit 1
else
exit 0
fi

##########################################################################

# These have been checked earlier. Should exist now.
. ${confFolder}/genomeBuildSetup.sh
. ${confFolder}/loadNeededTools.sh
. ${confFolder}/serverAddressAndPublicDiskSetup.sh

##########################################################################

if [ "${genomeSetupMade}" -eq 1 ]; then 

supportedGenomes=()
UCSC=()

setGenomeLocations 1>/dev/null

echo
sleep 4

echo "###########################################"
echo
echo "4) Listing the setup of allowed genomes"
echo


echo "Supported genomes : "
echo
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do    
 echo "${supportedGenomes[$g]}"
done

echo
sleep 2

##########################################################################
echo
echo "UCSC genome size files : "
echo
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do
    
 echo -en "${supportedGenomes[$g]}\t${UCSC[$g]}"
    
 if [ ! -e "${UCSC[$g]}" ] || [ ! -r "${UCSC[$g]}" ] || [ ! -s "${UCSC[$g]}" ]; then
    echo -e "\tFILE DOES NOT EXIST in the given location !!"
    exitCode=$(( ${exitCode} +1 ))
 else
    echo ""
 fi

done

echo
sleep 5


else
 
echo "###########################################"
echo
echo "4) Skipping genome setup testing ( as genomBuildSetup.sh was not filled with genome locations )"
echo   

sleep 3
 
fi

##########################################################################

if [ "${toolsSetupMade}" -eq 1 ]; then 

echo "###########################################"
echo
echo "5) Testing that all toolkits (bowtie etc) are found in the user-defined locations"
echo

setPathsForPipe 1>/dev/null

echo "Ucsctools .."
echo
bedGraphToBigWig 2>&1 | head -n 1
which bedGraphToBigWig >> /dev/null
exitCode=$(( ${exitCode} + $? ))
fetchChromSizes 2>&1 | head -n 1
which fetchChromSizes >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 3

echo "Bedtools .."
echo
bedtools --version
bedtools --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))

echo

sleep 2

echo "Perl .."
echo
perl --version | head -n 5 | grep -v "^\s*$"
perl --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "R and R-script"
echo
R --version | head -n 3
R --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo
echo
Rscript --version
Rscript --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 4

echo "Needed R libraries : ( DESeq2 , tidyverse, cowplot, RcolorBrewer ) "
echo

echo "DEseq2 .."
Rscript -e "suppressPackageStartupMessages(library(DESeq2))"
exitCode=$(( ${exitCode} + $? ))
# The above will print ERRORS to output log but not the succesfull loading messages.
echo
sleep 2

echo "tidyverse .."
Rscript -e "suppressPackageStartupMessages(library(tidyverse))"
exitCode=$(( ${exitCode} + $? ))
echo
sleep 2

echo "cowplot .."
Rscript -e "suppressPackageStartupMessages(library(cowplot))"
exitCode=$(( ${exitCode} + $? ))
echo
sleep 2

echo "RcolorBrewer .."
Rscript -e "suppressPackageStartupMessages(library(RColorBrewer))"
exitCode=$(( ${exitCode} + $? ))
echo

sleep 4

else
 
echo "###########################################"
echo
echo "5) Skipping toolkit availability testing ( as loadNeededTools.sh was not set up to find the proper tool locations )"
echo   

sleep 3
 
fi

##########################################################################

if [ "${serverSetupMade}" -eq 1 ]; then

echo "###########################################"
echo
echo "6) Testing that the user-defined public server exists"
echo

setPublicLocations 1>/dev/null

echo
echo "Public area settings : "
echo
echo "SERVERTYPE ${SERVERTYPE}"
echo "SERVERADDRESS ${SERVERADDRESS}"
echo "ADDtoPUBLICFILEPATH ${ADDtoPUBLICFILEPATH}"
echo "REMOVEfromPUBLICFILEPATH ${REMOVEfromPUBLICFILEPATH}"
echo "tobeREPLACEDinPUBLICFILEPATH ${tobeREPLACEDinPUBLICFILEPATH}"
echo "REPLACEwithThisInPUBLICFILEPATH ${REPLACEwithThisInPUBLICFILEPATH}"
echo

sleep 3

echo
echo "--------------------------------------------------------------------------"
echo "Testing the existence of public server ${SERVERTYPE}://${SERVERADDRESS} "
echo
echo "Any curl errors such as 'cannot resolve host' in the listing below, mean that the server is not available (possible typos in server name above ? ) "
echo
echo "curl --head ${SERVERTYPE}://${SERVERADDRESS} "
echo

curl --head ${SERVERTYPE}://${SERVERADDRESS}
exitCode=$(( ${exitCode} + $? ))

sleep 5

else
 
echo "###########################################"
echo
echo "6) Skipping public server existence testing ( as serverAddressAndPublicDiskSetup.sh was not filled with the server address )"
echo   

sleep 3
 
fi

# ##################################

if [ "${setupMade}" -ne 3 ]
then
echo 
echo
echo "ERROR : Could not finish testing, as you hadn't set up all of your environment !"
echo
echo "One or more of these need to be still set up :"
echo "1) genome locations"
echo "2) tool locations"
echo "3) server address"
echo 
echo "Set up your files according to instructions in :"
echo "http://sara.molbiol.ox.ac.uk/public/telenius/CCseqBasicManual/instructionsGeneral.html"
echo

exitCode=1

fi

# ##################################

# Return the value : 0 if only warnings, 1 if fatal problems.
if [ "${exitCode}" -gt 0 ]
then
exit 1
else
exit 0
fi

