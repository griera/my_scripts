#!/bin/bash

#
# my_fmt_name.sh:
#
# Usage: my_fmt_name.sh [-d] dir1_or_file1 dir2_or_file2 ...
#
# Formats file and directory names using the following rules (only ASCII
# characters are used):
#   · Removes whitespaces between '-', '+' and '&'
#   · Replaces all ampersands '&' to plus '+'
#   · Replaces parenthesis '(' ')' to brackets '[' ']'
#   · Removes whitespaces around brackets '[' ']'
#   · Replaces all commas ',' and their whitespaces around to underscores '_'
#   · Removes all '·'
#   · Replaces all whitespaces to underscores '_'
#   · Removes all tildes
# 
# These rules should be applied in all my personal files, directories and
# all configuration files that I can change its name (discarding those
# named by operating system).
# 
# The arguments accepted are paths to directories or files, whether they are
# relative or absolut. If an argument is a path to any directory, this script
# formats its name and the names of their contents recursively. Soft-links are
# also accepted as arguments
#
# Exit status:
#  · 0 -> Success
#  · 1 -> Fail (bad function usage, wrong number or defined argument. etc.)
#

function usage () {
    echo -e "Usage: $0 [-d] dir1_or_file1 dir2_or_file2 ...\n"
    echo -e "More information can be found by reading the script file."
    exit 1
}

function format () {
    local leaf_name="$1"
    leaf_name="${leaf_name// - /-}"
    leaf_name="${leaf_name// + /+}"
    leaf_name="${leaf_name// \& /+}"
    leaf_name="${leaf_name//\&/+}"
    leaf_name="${leaf_name//\(/[}"
    leaf_name="${leaf_name//\)/]}"
    leaf_name="${leaf_name// [/[}"
    leaf_name="${leaf_name//[ /[}"
    leaf_name="${leaf_name// ]/]}"
    leaf_name="${leaf_name//] /]}"
    leaf_name="${leaf_name//, /_}"
    leaf_name="${leaf_name//,/_}"
    leaf_name="${leaf_name// ,/_}"
    leaf_name="${leaf_name// , /_}"
    leaf_name="${leaf_name//·/}"
    leaf_name="$(echo ${leaf_name// /_} | iconv -f utf8 -t ascii//TRANSLIT)"
    echo "$leaf_name"
}


if [ $# -eq 0 ] ; then
    usage   
fi

BAK_IFS=$IFS
IFS=$'\n'

# Variable that defines debug mode status
DBG=0

# Check if first argument sets up '-d' flag (debug mode on)
if [ $1 = "-d" ] ; then
    DBG=1
    shift 1
fi

# Variable that defines if parameters are soft-links or not
softlink=0

for arg in "$@" ; do

    if ! [[ -e ${arg} ]] ; then
        echo ""${arg}": File or directory doesn't exist."
        continue
    fi

    # Check if $arg is a soft-link in order to do some additional tasks
    if [ -L ${arg} ] ; then
        softlink=1
        bak_arg=$arg
        arg=$(ls -l ${arg} | cut -d '>' -f2 | sed 's/^ *//g')
    fi

    # Check whether $arg is defined as an absolute or relative path.
    # Is needed to treat all arguments as absolute paths.
    # The same treatment is applied if $arg is a soft-link
    if [[ "$arg" != /* ]] ; then
        arg="${PWD}/${arg}"

        if [ ${softlink} -eq 1 ] ; then
            bak_arg="${PWD}/${bak_arg}"
        fi
    fi

    for elem in $(find "${arg}" | sort -r) ; do
        parent_dir="$(dirname ${elem})"
        leaf_name="$(basename ${elem})"
        fmtname="$(format "${leaf_name}")"

        if [ $DBG -eq 0 ] ; then
            mv "${elem}" "${parent_dir}/${fmtname}" &> /dev/null
        else
            mv "${elem}" "${parent_dir}/${fmtname}"
        fi
    done

    # Performs a format name operation when $arg is a soft-link
    if [ ${softlink} -eq 1 ] ; then
        bak_arg_parent="$(dirname "${bak_arg}")"
        bak_arg_leaf="$(basename "${bak_arg}")"
        bak_arg_leaf="$(format "${bak_arg_leaf}")"
        fmt_bak_arg="${bak_arg_parent}/${bak_arg_leaf}"
        
        if [ $DBG -eq 0 ] ; then
            mv "${bak_arg}" "${fmt_bak_arg}" &> /dev/null
        else
            mv "${bak_arg}" "${fmt_bak_arg}"
        fi

    fi

    # Check, when $arg is a soft-link, if the parent directory (the last elem
    # of the above list) has changed its name, in order to repair it
    if [[ ${softlink} -eq 1 && "$(basename $arg)" != "$fmtname" ]] ; then

        if [ $DBG -eq 0 ] ; then
            rm ${fmt_bak_arg} &> /dev/null
            ln -s "${parent_dir}/${fmtname}" "${fmt_bak_arg}" &> /dev/null
        else
            rm ${fmt_bak_arg}
            ln -s "${parent_dir}/${fmtname}" "${fmt_bak_arg}"
        fi
    fi

    softlink=0

done

IFS=$BAK_IFS

exit 0
