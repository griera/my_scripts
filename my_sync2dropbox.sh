#!/bin/bash

#
# my_sync2dropbox.sh:
#
# Usage: my_sync2dropbox.sh [-d] path_to_sync [alternative_path]
#
# Syncs file or directory specified as argument to Dropbox. This can be achieved
# by creating a softlink on Dropbox Ubuntu folder pointing to the specified
# file or directory, using always the same last name of the path (leaf name).
# By default, the file or directory will be synced into Dropbox's Ubuntu
# folder, but if an alternative path is specified, the file/directory will
# be located into $DROPBOX_DIR/alternative_path, creating the proper path tree
# structure.
#
# User variable $DROPBOX_DIR defines the path to Dropbox Ubuntu folder, and
# 'dropbox status' command show the current status of Dropbox daemon.
#
# Exit status:
#  · 0 -> Success
#  · 1 -> Fail (bad function usage, wrong number or defined argument. etc.)
#  · 2 -> File or directory specified as argument does not exists
#

function usage () {
    echo -e "Usage: $0 [-d] path_to_sync [alternative_path]\n"
    echo -e "More information can be found by reading the script file."
    exit 1
}

if [[ $# -eq 0 || $# -gt 3 || ($# -eq 1 && $1 = "-d") ]] ; then
    usage
fi

# Variable that defines debug mode status
DBG=0

# Check if first argument sets up '-d' flag (debug mode on)
if [ $1 = "-d" ] ; then
    DBG=1
    shift 1
fi

DROPBOX_DIR="/media/DADES/My_Folder/Dropbox"
path_to_sync="$1"

# Check if is defined an alternative path to sync the desired file/folder
# into Dropbox's folder
if [ "x$2" != "x" ] ; then
    alt_path=$2
    mkdir -p ${DROPBOX_DIR}/${alt_path}
fi

# Check dropbox daemon status
dropbox_status="$(dropbox.py status)"
if [ "${dropbox_status}" = "Dropbox isn't running!" ] ; then
    echo "WARNING: ${dropbox_status}"
    echo "${path_to_sync} will not be synched until Dropbox daemon starts."
fi
    
# Check whether $path_to_sync is defined as an absolute or relative path.
# Is needed to treat all arguments as absolute paths.
[[ "$path_to_sync" != /* ]] && path_to_sync="${PWD}/${path_to_sync}"

# Checks if $path_to_sync exists
if ! [[ -e ${path_to_sync} ]] ; then
    echo "${path_to_sync}: File or directory doesn't exist."
    echo "Nothing to be synched on Dropbox."
    exit 2
fi
    
leaf_name="$(basename ${path_to_sync})"
if [ $DBG -eq 0 ] ; then
    ln -s "${path_to_sync}" "${DROPBOX_DIR}/${alt_path}/${leaf_name}" &> /dev/null
else
    ln -s "${path_to_sync}" "${DROPBOX_DIR}/${alt_path}/${leaf_name}"
fi

exit 0
