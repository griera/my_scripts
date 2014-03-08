#!/bin/bash

#
# my_webpage2pdf.sh:
#
# Usage: my_webpage2pdf.sh [-d] "URL" [filename]
#
# Downloads webpage from URL specified as first argument and converts all their
# .html files into a single .pdf file. "URL" is the only mandatory argument and
# must be surrounded by quotes. [filename] argument is optional, and it
# contains the PDF file name on which webpage will be stored (no needs to
# incldue .pdf extension on file name). If no [filename] is specified, then the
# output file will be will be called "webpage.pdf". In both cases, the resulting
# PDF file will be generated on working/current directory.
#
# It's important to note that wkhtmltopdf and pdftk are needed for the script.
# Install them using sudo apt-get install wkhtmltopdf pdftk if you have none.
#
# Exit status:
#  · 0 -> Success
#  · 1 -> Fail (bad function usage, wrong number or defined argument. etc.)
#  · 2 -> Some needed packages are not currently installed.
#

function usage() {
    echo "Usage: $0 [-d] \"URL\" [filename]"
    echo "\"URL\" must be surrounded by quotes."
    echo "More information can be found by reading the script file."
    exit 1
}

function no_pack_inst() {
    echo "$1 is not installed."
    echo "Please install it using \"sudo apt-get install $1\""
    echo "Terminating execution."
    exit 2
}

if [[ $# -eq 0 || $# -gt 3 || ($# -eq 1 && $1 = "-d") ]] ; then
    usage
fi

# Checks if all needed packages are installed
man wkhtmltopdf &> /dev/null
if [ $? -ne 0 ] ; then
    no_pack_inst "wkhtmltopdf"
fi

man pdftk &> /dev/null
if [ $? -ne 0 ] ; then
    no_pack_inst "pdftk"
fi

# Variable that defines debug mode status
DBG=0

# Check if first argument sets up '-d' flag (debug mode on)
if [ $1 = "-d" ] ; then
    DBG=1
    shift 1
fi

# Defines needed variables
URL="$1"
DOMAIN="$(echo ${URL} | sed -e 's/http:\/\///' -e 's/www.//' -e 's/\/.*//')"
TMPDIR="/media/DADES/tmpdir"

# Checks if is defined an output file
if [ "x$2" != "x" ] ; then
    FILENAME="$(basename $2)"
    echo "$FILENAME" | grep -q ".pdf"

    if [ $? -ne 0 ] ; then
        FILENAME="${FILENAME}.pdf"
    fi

else
    FILENAME="webpage.pdf"
fi

# Checks if debugg mode is enabled
if [ ${DBG} -eq 0 ] ; then
    QUIET="--quiet"
fi

# Stores webpage into $TMPDIR local temporary directory 
echo "Downloading ${URL} ..."

wget                    \
    --mirror            \
    --recursive         \
    --page-requisites   \
    --html-extension    \
    --convert-links     \
    --domains ${DOMAIN} \
    --no-parent         \
    ${QUIET} ${URL} -P ${TMPDIR}

# Collects all .html files from the hierarchy directory structure of webpage
echo "Collecting files from subfolders..."

if [ ${DBG} -eq 0 ] ; then
    for filename in $(find ${TMPDIR} -type f -name '*\.html' -print | sed 's/^\.\///')
    do
        mv ${filename} ${TMPDIR}/$(basename ${filename}) &> /dev/null
    done
else
    for filename in $(find ${TMPDIR} -type f -name '*\.html' -print | sed 's/^\.\///')
    do
        mv ${filename} ${TMPDIR}/$(basename ${filename})
    done
fi

# Converts all .html files into .pdf files
echo "Converting into PDF files..."

if [ ${DBG} -eq 0 ] ; then
    find ${TMPDIR} -name \*.html | sed 's/.html$//g' | xargs -n 1 -I X wkhtmltopdf --quiet X.html X.pdf &> /dev/null
else
    find ${TMPDIR} -name \*.html | sed 's/.html$//g' | xargs -n 1 -I X wkhtmltopdf --quiet X.html X.pdf
fi

# Concatenates all .pdf into a single .pdf file
echo "Concatenating the PDF files..."

if [ ${DBG} -eq 0 ] ; then
    pdftk ${TMPDIR}/*.pdf cat output ${FILENAME} &> /dev/null
else
    pdftk ${TMPDIR}/*.pdf cat output ${FILENAME}
fi

# Removes stored webpage
if [ ${DBG} -eq 0 ] ; then
    rm -r ${TMPDIR} &> /dev/null
else
    rm -r ${TMPDIR}
fi

echo "SUCCESS: ${FILENAME} has been generated successfully on working/current directory."
exit

