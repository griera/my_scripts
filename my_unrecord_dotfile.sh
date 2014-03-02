#!/bin/bash

#
# my_unrecord_dotfile.sh
#
# Usage: my_unrecord_dotfile.sh [-d] dotfile_name
#
# Undoes the recorded dotfile by removing its soft-link located on dotfile's
# original location and moves the original dotfile located in my general
# dotfile's folder, i.e., ~/my_dotfiles/ to its original location.
# Then removes its entry inside the specific record text file:
# ~/my_dotfile/dotfile_record.txt
# 
# Exit status:
#  · 0 -> Success
#  · 1 -> Fail (bad function usage, wrong number of defined argument. etc.)
#  · 2 -> Dotfile specified as argument does not exists, or it's not recorded
#

function usage () {
    echo -e "Usage: $0 [-d] dotfile_name\n"
    echo -e "More information can be found by reading the script file."
    exit 1
}

# General purpose variable
DOTFILE_DIR=~/my_dotfiles
RECORD_FILE=${DOTFILE_DIR}/dotfiles_record.txt

if [[ $# -eq 0 || $# -gt 2 || ($# -eq 1 && $1 = "-d") ]] ; then
    usage
fi

# Variable that defines debug mode status
DBG=0

# Check if first argument sets up '-d' flag (debug mode on)
if [ $1 = "-d" ] ; then
    DBG=1
    shift 1
fi

# Removes, if exists, trailing slash (when argument is a directory)
dotfile_name=${1%/}

# Check if dotfile_name exists in $RECORD_FILE
if [ $DBG -eq 0 ] ; then
    cut -d ' ' -f1 $RECORD_FILE | grep -x $dotfile_name &> /dev/null
else
    cut -d ' ' -f1 $RECORD_FILE | grep -x $dotfile_name
fi

if [ $? -eq 0 ] ; then
    path_to_dotfile=$(cut -d ' ' -f2 $RECORD_FILE | grep $dotfile_name)
else
    echo "$dotfile_name is not recorded."
    exit 2
fi

if [ $DBG -eq 0 ] ; then
    rm -r $path_to_dotfile &> /dev/null
    mv ${DOTFILE_DIR}/$dotfile_name $path_to_dotfile &> /dev/null
    sed -i -e "/$dotfile_name/d" $RECORD_FILE &> /dev/null  
else
    rm -r $path_to_dotfile
    mv ${DOTFILE_DIR}/$dotfile_name $path_to_dotfile
    sed -i -e "/$dotfile_name/d" $RECORD_FILE
fi

exit 0

