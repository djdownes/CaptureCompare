#!/bin/bash -l
#$ -cwd

#########################################################################################
#                                                                                       #
# Copyright 2018, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)                        #
#                                                                                       #
#########################################################################################

testInputParameters(){
# If any of the parameters is empty, contains ONLY whitespace, or has whitespace within the value (contains spaces etc) - crashes with easy-to-interpret error message.

printThis="Checking input parameters .."
printToLogFile

if [ "${analysis}" != "2way" ] && [ "${analysis}" != "3way" ]
    then
    printThis="Analysis type not found : '${analysis}' (only types '2way' and '3way' are allowed)  \nEXITING!! "
    printToLogFile
    exit 1
    fi

checkThis="${analysis}"
checkedName='--analysis'
checkParse
# The above sub comes from helpersubs.sh
# It checks that there is 1) SOMETHING in this parameter. 2) there is not ONLY whitespace in the parameter. 3) there is no whitespace in the middle of the parameter value (contains no spaces etc).
# If it fails, it crashes the whole run with easy-to-interpret error message.

checkThis="${path}"
checkedName='--path'
checkParse

checkThis="${sample1}"
checkedName='--sample1'
checkParse

checkThis="${sample2}"
checkedName='--sample2'
checkParse

if [ "${sample3}" != "" ]
    then
    checkThis="${sample3}"
    checkedName='--sample3'
    checkParse
    fi

checkThis="${directories}"
checkedName='--directories'
checkParse

checkThis="${name}"
checkedName='--name'
checkParse

checkThis="${genome}"
checkedName='--genome'
checkParse

checkThis="${REenzyme}"
checkedName='--restrictionenzyme'
checkParse

checkThis="${version}"
checkedName='--version'
checkParse

checkThis="${parameters}"
checkedName='--parameters'
checkParse

checkThis="${annotation}"
checkedName='--annotation'
checkParse

checkThis="${PublicPath}"
checkedName='--public'
checkParseOnlyWarning
# As public folder may not be set - depending on how external users want to use this
# (believe or not - some of them will not want to use hubs)

# After the parse tests, checking also the existence of the files and folders ..

testedFile="${parameters}"
doInputFileTesting
# The above sub comes from helpersubs.sh
# It checks that 1) the file exists 2) the file is readable (user has reading permissions) 3) the file is not empty
# If it fails, it crashes the whole run with easy-to-interpret error message.

testedFile="${annotation}"
doInputFileTesting
# The above sub comes from helpersubs.sh
# It checks that 1) the file exists 2) the file is readable (user has reading permissions) 3) the file is not empty
# If it fails, it crashes the whole run with easy-to-interpret error message.

testedFolder="${path}"
folderTesting
# The above sub comes from helpersubs.sh
# It checks that 1) the folder exists 2) the folder is readable (user has reading permissions)
# If it fails, it crashes the whole run with easy-to-interpret error message.

printThis="Input parameters fine "
printToLogFile

}

testInputDirectories(){
    
printThis="Checking input folders..."
printToLogFile

# Check that all the dirs exist (no typos in dir name and path, thus)
# Checks that the dirs can be found, in the required format
# ${path}/${name}/F6_greenGraphs_combined_${name}_${version}

TEMPdirs=($( echo "${directories}" | sed 's/,$//' | tr ',' '\n' ))
# the $() construct means "output of the command within the brackets" - the part which goes to STDOUT not STDERR
# () around it means "make it an array" - so this is what makes TEMPdirs an array.

for tempdir in "${TEMPdirs[@]}"
do

printThis="Folder ${tempdir}, ran with CCseqBasic version ${version}"
printToLogFile

testedFolder="${path}/${tempdir}/F6_greenGraphs_combined_${tempdir}_${version}"
folderTesting
# The above sub comes from helpersubs.sh
# It checks that 1) the folder exists 2) the folder is readable (user has reading permissions)
# If it fails, it crashes the whole run with easy-to-interpret error message.


done

printThis="Input folders fine."
printToLogFile

}

loadConfigFiles(){

peakyREfragBed="${configdir}/REfragmentFiles/${genome}_${REenzyme}_Fragments.txt"

# Generate this on the fly, if it doesn't exist ..

if [ ! -s "${peakyREfragBed}" ]
    then
    
    # Running the digestion ..
    # dpnIIcutGenome.pl
    # nlaIIIcutGenome.pl   

    printThis="Running whole genome fasta ${REenzyme} digestion.."
    printToLogFile

    printThis="perl ${scriptdir}/${REenzyme}cutGenome4.pl ${GenomeFasta}"
    printToLogFile

    perl ${RunScriptsPath}/${REenzyme}cutGenome4.pl "${GenomeFasta}"
    
    peakyREfragBed=$(pwd)"/genome_${REenzyme}_coordinates.txt"    
    
    fi


testedFile="${peakyREfragBed}"
doFileTesting

}
