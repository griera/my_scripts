#!/bin/bash

# my_bak_nexus5.sh:
#
# Usage: my_bak_nexus5.sh [-d] [-r]
#
# Copies the most recent backup of systems+user apps and data made by
# Titanium Backup app from my Nexus 5 to my desktop computer. Also saves
# the backup if it's locate on my personal pen drive.
#
# IMPORTANT NOTE: It's needed to restart Nexus 5 before starting the backup
# process!
#
# Exit status:
# · 0 -> Success
# · 1 -> Fail (bad function usage, wrong number or defined argument. etc.)
# · 2 -> Neither Nexus 5 nor pen drive are not connected to the computer
#

function usage () {
    echo -e "Usage: $0 [-d] [-r]\n"
    echo -e "More information can be found by reading the script file."
    exit 1
}

OUTPUT_DIR="${HOME}/my_links/Smartphones/Nexus_5/TitaniumBackup/"
NEXUS5_SSH_PATH="/storage/emulated/0"
NEXUS5_USB_PATH="${HOME}/my_links/Nexus5"
PEN_DRIVE_PATH="${HOME}/my_links/GENIS_DATA1"

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

# Checks if Nexus 5 has a SSH Server listening for incoming connections, or is connected to the computer via USB
# or a pen drive are connected to the computer
NEXUS5_USB_LINK="$(ls -l ${NEXUS5_USB_PATH} | cut -d '>' -f2 | sed 's/^ *//')"
PEN_DRIVE_LINK="$(ls -l ${PEN_DRIVE_PATH} | cut -d '>' -f2 | sed 's/^ *//')"
SELECTED_PATH="${NEXUS5_SSH_PATH}"
SELECTED_SOURCE="Nexus 5 SSH Server"
ssh nexus-phone ls &> /dev/null

if [ $? -ne 0 ] ; then
    echo "WARNING: Nexus 5 SSH Server is not listening for incoming connections. Try to connect via USB..."
    SELECTED_PATH="${NEXUS5_USB_PATH}"
    SELECTED_SOURCE="Nexus 5 USB"
    if [ ! -e "${NEXUS5_LINK}" ] ; then
        echo -n "WARNING: ${SELECTED_SOURCE} is not connected. "
        SELECTED_PATH="${PEN_DRIVE_PATH}"
        SELECTED_SOURCE="pen drive"
        echo "Trying to connect to ${SELECTED_SOURCE} instead..."
        if [ ! -e "${PEN_DRIVE_LINK}" ] ; then
            echo "WARNING: ${SELECTED_SOURCE} is not connected, too."
            echo "Please start SSH Server on Nexus 5, plug Nexus 5 or pen drive into your computer and executes the script again."
            exit 2
        fi
    fi
fi

# Checks if the selected source (Nexus 5 or pen drive) has a backup made by Titanium Backup
TBAK_PATH="${SELECTED_PATH}/TitaniumBackup/"

if [ "${SELECTED_SOURCE}" = "Nexus 5 SSH Server" ] ; then
    if [ "$(ssh nexus-phone ls -la ${TBAK_PATH} | wc -l)" -le 3 ] ; then
        echo "There isn't any backup made by Titanium Backup on ${SELECTED_SOURCE}."
        echo "The copy will not be performed. Exiting."
        exit 0
    fi
else
    if [ "$(ls -la ${TBAK_PATH} | wc -l)" -le 3 ] ; then
        echo "There isn't any backup made by Titanium Backup on ${SELECTED_SOURCE}."
        echo "The copy will not be performed. Exiting."
        exit 0
    fi
fi

if [ "${SELECTED_SOURCE}" = "Nexus 5 SSH Server" ] ; then
    LAST_DATE_BAK="$(ssh nexus-phone ls -la ${TBAK_PATH} | tr -s ' ' | cut -d ' ' -f5 | sort | uniq | tail -n 1)"
else
    LAST_DATE_BAK="$(ls -l --full-time ${TBAK_PATH} | tr -s ' ' | cut -d ' ' -f6 | sort | uniq | tail -n 1)"
fi

PREFIX="backup_Nexus5"
BAK_NAME="${PREFIX}_${LAST_DATE_BAK}.tar.gz"

echo -ne "Copying backup from ${SELECTED_SOURCE} (${TBAK_PATH}) using the name ${BAK_NAME} "
echo "into the following directory:"
echo -e "${OUTPUT_DIR}\nWait for a while...\n"

if [ "${SELECTED_SOURCE}" = "Nexus 5 SSH Server" ] ; then
    TMP_DIR="${OUTPUT_DIR}/$(echo $BAK_NAME | cut -d '.' -f1)"
    if [ ${DBG} -eq 1 ] ; then
        scp -r -p nexus-phone:${TBAK_PATH} $TMP_DIR
        tar czvf ${OUTPUT_DIR}/${BAK_NAME} $TMP_DIR
        rm -r $TMP_DIR
    else
        scp -r -p nexus-phone:${TBAK_PATH} $TMP_DIR &> /dev/null
        tar czvf ${OUTPUT_DIR}/${BAK_NAME} $TMP_DIR &> /dev/null
        rm -r $TMP_DIR &> /dev/null
    fi
else
    if [ ${DBG} -eq 1 ] ; then
        tar czvf ${OUTPUT_DIR}/${BAK_NAME} ${TBAK_PATH}
    else
        tar czvf ${OUTPUT_DIR}/${BAK_NAME} ${TBAK_PATH} &> /dev/null
    fi
fi

if [ ${REM_OLD_BAKS} -eq 1 ] ; then
    echo -e "Removing old backups from desktop computer directory:\n${OUTPUT_DIR}\nWait for a while...\n"
    ls ${OUTPUT_DIR}/${PREFIX}* | head -n -1 | xargs rm
fi

echo "Backup has been copied to desktop computer successfully!"
exit 0

