#!/bin/bash

#
# my_git_status_all.sh:
# 
# Usage: my_git_status_all.sh
# 
# Outputs the current status of all GitHub local repositories.
#
# Exit status:
#  · 0 -> Success
#

function print_hyphens() {
    num_chars="$(echo "$1" | wc -m)"
    num_side_hyphens=$(( (82 - ${num_chars} - 1) / 2))

    for i in $(seq 0 ${num_side_hyphens}) ; do
        echo -n "-"
    done
}

REPOS_PATH="${HOME}/repos"
TMP_FILE="/tmp/log.txt"
REPOS_MOD=""
for repo in $(ls ${REPOS_PATH}) ; do
    cd ${REPOS_PATH}/${repo}
    MSG="  GIT STATUS OF REPOSITORY ${repo}  "

    print_hyphens "${MSG}"
    echo -n "${MSG}"
    print_hyphens "${MSG}"
    echo ""

    git status | tee /tmp/log.txt
    grep -w "nothing to commit (working directory clean)" ${TMP_FILE} &> /dev/null

    if [ $? -ne 0 ] ; then
        REPOS_MOD="${REPOS_MOD} ${repo}"
    fi
    echo -e "\n----------------------------------------------------------------------------------"
    echo -e "----------------------------------------------------------------------------------\n"
done
rm ${TMP_FILE}

if [ "x${REPOS_MOD}" = "x" ] ; then
    echo "All your repositories are clean"
else
    echo "The following repositories have changed:"
    for i in $(echo ${REPOS_MOD}) ; do
        echo ${i}
    done
fi
exit 0

