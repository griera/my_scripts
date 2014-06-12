#!/bin/bash

# my_bak_nexus5.sh:
#
# Usage: my_bak_nexus5.sh [-d]
#
# Copies the most recent backup of systems+user apps and data made by
# Titanium Backup app from my Nexus 5 to my desktop computer.
#
# Exit status:
# · 0 -> Success
# · 1 -> Fail (bad function usage, wrong number or defined argument. etc.)
# · 2 -> Nexus 5 is not connected to the computer
#

function usage () {
    echo -e "Usage: $0 [-d]\n"
    echo -e "More information can be found by reading the script file."
    exit 1
}

OUTPUT_DIR="${HOME}/my_links/Smartphones/Nexus_5/TitaniumBackup/"
NEXUS5_PATH="${HOME}/my_links/Nexus5"

# Checks user parameters
if [[ $# -gt 2 || ($# -eq 1 && ($1 != "-d" && $1 != "-r")) || ($# -eq 2 && ($1 != "-d" || $2 != "-r")) ]] ; then
    usage
fi


# Variable that defines debug mode status
DBG=0

# Check if first argument sets up '-d' flag (debug mode on)
if [ "$1" = "-d" ] ; then
    DBG=1
    shift 1
fi

# Variable that defines if is needed to remove old backups
REM_OLD_BAKS=0

# Check if second argument sets up '-r' flag (remove old backups)
if [ "$1" = "-r" ] ; then
    REM_OLD_BAKS=1
    shift 1
fi

# Checks if Nexus 5 is connected to the computer
NEXUS5_LINK="$(ls -l ${NEXUS5_PATH} | cut -d '>' -f2 | sed 's/^ *//')"
if [ ! -e "${NEXUS5_LINK}" ] ; then
    echo "Nexus 5 is not connected. Please plug it into your computer and executes the script again"
    exit 2
fi

# Checks if Nexus 5 has a backup made by Titanium Backup
TBAK_PATH="${NEXUS5_PATH}/TitaniumBackup/"
if [ "$(ls -la ${TBAK_PATH} | wc -l)" -le 3 ] ; then
    echo "There isn't any backup made Titanium Backup on Nexus 5."
    echo "The copy will not be performed. Exiting."
    exit 0
fi

LAST_DATE_BAK="$(ls -l --full-time ${TBAK_PATH} | tr -s ' ' | cut -d ' ' -f6 | sort | uniq | tail -n 1)"
PREFIX="backup_Nexus5"
BAK_NAME="${PREFIX}_${LAST_DATE_BAK}.tar.gz"

echo -e "Copying backup from Nexus 5 (${TBAK_PATH}) using the name ${BAK_NAME} into the following directory:"
echo -e "${OUTPUT_DIR}\nWait for a while...\n"
if [ ${DBG} -eq 1 ] ; then
    tar czvf ${OUTPUT_DIR}/${BAK_NAME} ${TBAK_PATH}
else
    tar czvf ${OUTPUT_DIR}/${BAK_NAME} ${TBAK_PATH} &> /dev/null
fi

if [ ${REM_OLD_BAKS} -eq 1 ] ; then
    echo -e "Removing old backups from desktop computer directory:\n${OUTPUT_DIR}\nWait for a while...\n"
    ls ${OUTPUT_DIR}/${PREFIX}* | head -n -1 | xargs rm
fi

echo "Backup has been copied to desktop computer successfully!"
exit 0

