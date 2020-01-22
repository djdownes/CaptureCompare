#!/bin/bash -l
#$ -cwd

#########################################################################################
#                                                                                       #
# Copyright 2018, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)                        #
#                                                                                       #
#########################################################################################

printToLogFile(){
   
# Needs this to be set :
# printThis="" 

echo ""
echo -e "${printThis}"
echo ""

echo "" >> "/dev/stderr"
echo -e "${printThis}" >> "/dev/stderr"
echo "" >> "/dev/stderr"
    
}

doInputFileTesting(){
    
    # NEEDS THIS TO BE SET BEFORE CALL :
    # testedFile=""    
    
    if [ ! -r "${testedFile}" ] || [ ! -e "${testedFile}" ] || [ ! -f "${testedFile}" ] || [ ! -s "${testedFile}" ]; then
      printThis="Input file not found or empty file : ${testedFile}  \nEXITING!! "
      printToLogFile
      exit 1
    fi
}

doTempFileTesting(){
    
    # NEEDS THIS TO BE SET BEFORE CALL :
    # testedFile=""    
    
    if [ ! -r "${testedFile}" ] || [ ! -e "${testedFile}" ] || [ ! -f "${testedFile}" ] || [ ! -s "${testedFile}" ]; then
      printThis="Temporary file not found or empty file : ${testedFile} \nEXITING!! "
      printToLogFile
      exit 1
fi
}


fileTesting(){
    
    # NEEDS THIS TO BE SET BEFORE CALL :
    # testedFile=""    
    
    if [ ! -s "${testedFile}" ] || [ ! -r "${testedFile}" ] || [ ! -f "${testedFile}" ] ; then
      printThis="File not found or cannot be read or empty file : ${testedFile} \nEXITING!! "
      printToLogFile
      exit 1
    fi
}

folderTesting(){
    
    # NEEDS THIS TO BE SET BEFORE CALL :
    # testedFolder=""    
    
    if [ ! -d "${testedFolder}" ] || [ ! -r "${testedFolder}" ] ; then
      printThis="Folder not found or cannot be read : ${testedFolder} \nEXITING!! "
      printToLogFile
      exit 1
    fi
}

checkParse(){

# checkThis=
# checkedName=

if [ "${#checkThis}" -eq 0 ]; then
  printThis="Parse fail - zero lenght variable ${checkedName} ! \nEXITING"
  printToLogFile
  exit 1
fi

whiteSpaceParsed=$(echo ${checkThis} | sed 's/\s*//g' )
if [ "${#whiteSpaceParsed}" -eq 0 ]; then
  printThis="Parse fail - variable ${checkedName}='${checkThis}' only contains whitespace ! \nEXITING"
  printToLogFile
  exit 1
fi

# last test : whitespace in the middle of variable name !

stillContainsWhitespace=$( echo "${checkThis}" |  grep -c '\s' )
if [ "${stillContainsWhitespace}" -ne 0 ]; then
  printThis="Parse fail - variable ${checkedName}='${checkThis}' contains whitespace in the middle of variable ! \nEXITING"
  printToLogFile
  exit 1
fi
    
}

checkParseOnlyWarning(){

# checkThis=
# checkedName=

if [ "${#checkThis}" -eq 0 ]; then
  printThis="WARNING : Parse fail - zero lenght variable ${checkedName} !"
  printToLogFile
fi

whiteSpaceParsed=$(echo ${checkThis} | sed 's/\s*//g' )
if [ "${#whiteSpaceParsed}" -eq 0 ]; then
  printThis="WARNING : Parse fail - variable ${checkedName}='${checkThis}' only contains whitespace ! "
  printToLogFile
fi

# last test : whitespace in the middle of variable name !

stillContainsWhitespace=$( echo "${checkThis}" |  grep -c '\s' )
if [ "${stillContainsWhitespace}" -ne 0 ]; then
  printThis="WARNING : Parse fail - variable ${checkedName}='${checkThis}' contains whitespace in the middle of variable ! "
  printToLogFile
fi
    
}

isThisPublicFolderParsedFineAndMineToMeddle(){
# thisPublicFolder=
# thisPublicFolderName=

# This only works for FOLDERS (below we have extension also for files -  but that parse is not working properly)


if [ "${#thisPublicFolder}" -eq 0 ]; then
  printThis="The public folder ${thisPublicFolderName} folder name ${thisPublicFolder} has zero lenght \nEXITING"
  if [ "${thisIsTesterLoggerTest}" != "" ];then printToTesterLogFile; testerLooperSingleTestPassedOK=0; else printToLogFile; exit 1; fi
fi

whiteSpaceParsed=$(echo ${thisPublicFolder} | sed 's/\s*//g' )
if [ "${#whiteSpaceParsed}" -eq 0 ]; then
  printThis="The public folder ${thisPublicFolderName} folder name ${thisPublicFolder} contains only whitespace \nEXITING"
  if [ "${thisIsTesterLoggerTest}" != "" ];then printToTesterLogFile; testerLooperSingleTestPassedOK=0; else printToLogFile; exit 1; fi
fi

# Next test : whitespace in the middle of variable name !

stillContainsWhitespace=$( echo "${thisPublicFolder}" |  grep -c '\s' )
if [ "${stillContainsWhitespace}" -ne 0 ]; then
  printThis="The public folder ${thisPublicFolderName} folder name '${thisPublicFolder}' contains whitespace in the middle of the folder name \nEXITING"
  if [ "${thisIsTesterLoggerTest}" != "" ];then printToTesterLogFile; testerLooperSingleTestPassedOK=0; else printToLogFile; exit 1; fi
fi

# Here two situations - whether we have folder or we have file.

if [ -d "${thisPublicFolder}" ]; then
{    
# Here safety check - that the person actually OWNS THIS FOLDER.
# If not, then refusing right here. (then it is actually not generated by a previous CCanalyser run ran by this very same person, for sure ! )
thisIsMineToMeddle=1
thisIsMineToMeddle=$(($( ls -l $(dirname ${thisPublicFolder}) | grep $(basename ${thisPublicFolder}) | sed 's/\s\s*/\t/g' | cut -f 3 | grep -c $(whoami) )))
if [ "${thisIsMineToMeddle}" -eq 0 ]; then
    printThis="The public folder ${thisPublicFolderName} ${thisPublicFolder} is not owned by $(whoami), so refusing to meddle with it ! \n EXITING!!  \n "$( ls -l $(dirname ${thisPublicFolder}) | grep $(basename ${thisPublicFolder}))
    if [ "${thisIsTesterLoggerTest}" != "" ];then printToTesterLogFile; testerLooperSingleTestPassedOK=0; else printToLogFile; exit 1; fi
fi   
}

else
{    
# Here safety check - that the person actually OWNS THE FOLDER the file belongs to.
# If not, then refusing right here. (then it is actually not generated by a previous CCanalyser run ran by this very same person, for sure ! )
thisIsMineToMeddle=0
if [ "${thisIsMineToMeddle}" -eq 0 ]; then
    printThis="The public folder ${thisPublicFolderName} ${thisPublicFolder} does not exist, so cannot test if it is fine to meddle ! \n EXITING!! \n "
    if [ "${thisIsTesterLoggerTest}" != "" ];then printToTesterLogFile; testerLooperSingleTestPassedOK=0; else printToLogFile; exit 1; fi
fi   
}   
    
fi
    
    
}