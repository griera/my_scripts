#!/bin/bash

#
# my_add_dotfile.sh
#
# Usage: my_add_dotfile.sh [-d] path_to_dotfile
#
# Moves the original dotfile located in path_to_dotfile to my general dotfile's
# folder, i.e., ~/my_dotfiles/. Then creates a soft-link in its original
# location, with the same basename, pointing to the previous copy.
# Also, the script keeps a record of what dotfiles have been added until now in
# a specific text file: ~/my_dotfile/dotfile_record.txt, using the following
# format (one line for each recorded dotfile):
#
# dotfile_name [whitespace] original_path_to_dotfile
#
# Exit status:
#  · 0 -> Success
#  · 1 -> Fail (bad function usage, wrong number of defined argument. etc.)
#  · 2 -> Dotfile specified as argument does not exists, or its path is wrong
#  · 3 -> Dotfile specified as argument is already registered
#

function usage () {
    echo -e "Usage: $0 [-d] path_to_dotfile\n"
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
path_to_dotfile=${1%/}

# Check whether $path_to_dotfile is defined as an absolute or relative path.
# Is needed to treat all arguments as absolute paths.
[[ "$path_to_dotfile" != /* ]] && path_to_dotfile="${PWD}/${path_to_dotfile}"

# Checks if $path_to_dotfile exists
if ! [[ -e $path_to_dotfile ]] ; then
    echo "$path_to_dotfile: File or directory doesn't exist."
    echo "No dotfile to be recorded."
    exit 2
fi

dotfile_name="$(basename "$path_to_dotfile")"

# Check if $path_to_dotfile is already registered in $RECORD_FILE
if [ $DBG -eq 0 ] ; then
    grep -x "$dotfile_name $path_to_dotfile" $RECORD_FILE &> /dev/null
else
    grep -x "$dotfile_name $path_to_dotfile" $RECORD_FILE
fi

if [ $? -eq 0 ] ; then
    echo "$path_to_dotfile is already registered."
    echo "No dotfile to be recorded."
    exit 3
fi

if [ $DBG -eq 0 ] ; then
    mv $path_to_dotfile ${DOTFILE_DIR}/ &> /dev/null
    ln -s ${DOTFILE_DIR}/${dotfile_name} $path_to_dotfile &> /dev/null
    echo "$dotfile_name $path_to_dotfile" 2> /dev/null >> $RECORD_FILE
    sort $RECORD_FILE -o $RECORD_FILE &> /dev/null

else
    mv $path_to_dotfile ${DOTFILE_DIR}/
    ln -s ${DOTFILE_DIR}/${dotfile_name} $path_to_dotfile
    echo "$dotfile_name $path_to_dotfile" >> $RECORD_FILE
    sort $RECORD_FILE -o $RECORD_FILE
fi

exit 0

