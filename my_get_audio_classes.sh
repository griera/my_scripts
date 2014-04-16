#!/bin/bash

#
# my_get_audio_classes.sh:
#
# Usage: my_get_audio_classes.sh [-d]
#
# Gets all audio classes recorded from my Nexus 5 and, depending on the
# subject, puts them in their proper directories of my desktop computer.
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

NEXUS5_PATH="${HOME}/my_links/Nexus5"
SUBJECTS_PATH="/media/DADES/My_Folder/Studies/FIB/"
AUDIOS_DIR="Audios"
SUBJECT=""
OUTPUT_DIR=""

# Matches one date and hour to its respective subject and defines properly the
# destination directory
function get_subject() {
    case "$1" in
    'dimarts_16')
        SUBJECT="SO2"
        OUTPUT_DIR="$(find ${SUBJECTS_PATH} -name SO2 -type d)/${AUDIOS_DIR}"
        ;;

    'dilluns_18')
        SUBJECT="PAP"
        OUTPUT_DIR="$(find ${SUBJECTS_PATH} -name PAP -type d)/${AUDIOS_DIR}"
        ;;
    esac
}

# Checks user parameters
if [[ $# -gt 1 || ($# -eq 1 && $1 != "-d") ]] ; then
    usage
fi

# Variable that defines debug mode status
DBG=0

# Check if first argument sets up '-d' flag (debug mode on)
if [ "$1" = "-d" ] ; then
    DBG=1
    shift 1
fi

# Checks if Nexus 5 is connected to the computer
NEXUS5_LINK="$(ls -l ${NEXUS5_PATH} | cut -d '>' -f2 | sed 's/^ *//')"
if [ ! -e "${NEXUS5_LINK}" ] ; then
    echo "Nexus 5 is not connected. Please plug it into your computer and executes the script again"
    exit 2
fi

RECS_PATH="${NEXUS5_PATH}/Genis_Data/Recordings"

for rec in $(ls ${RECS_PATH}) ; do
    REC_DATE="$(echo ${rec} | cut -d '_' -f1)"
    REC_DAY="$(date -d ${REC_DATE} +%A)"
    REC_HOUR="$(echo ${rec} | cut -d '_' -f2 | cut -d '-' -f1)"
    REC_FORMAT="$(echo ${rec} | cut -d '.' -f2)"

    get_subject "${REC_DAY}_${REC_HOUR}"
  
    if [ "x${SUBJECT}" = "x" ] ; then
        echo "The recording named ${rec} does not belong to any class. Skips it."
    else
        AUDIO_NAME="${SUBJECT}_${REC_DATE}.${REC_FORMAT}"
        echo -e "Copying audio file ${rec} from Nexus 5 using the name ${AUDIO_NAME} into the following directory:\n${OUTPUT_DIR}/\nWait for a while...\n"
        if [ ${DBG} -eq 1 ] ; then
            cp ${RECS_PATH}/${rec} ${OUTPUT_DIR}/${AUDIO_NAME}
        else
            cp ${RECS_PATH}/${rec} ${OUTPUT_DIR}/${AUDIO_NAME} &> /dev/null
        fi
    fi

    # Resets their values for the next audio file
    OUTPUT_DIR=""
    SUBJECT=""
done

echo "All audio files have been tranfered into their directories successfully!"
exit 0

