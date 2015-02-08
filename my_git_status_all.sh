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

REPOS_DIR="${HOME}/repos"
REPOS_MOD=""
for repo in $(ls ${REPOS_DIR}) ; do
    cd ${REPOS_DIR}/${repo}
    MSG="  GIT STATUS OF REPOSITORY ${repo}  "

    print_hyphens "${MSG}"
    echo -n "${MSG}"
    print_hyphens "${MSG}"
    echo ""

    git status
    git_status="$(git status)"
    echo $git_status | grep -wq "working directory clean"

    if [ $? -ne 0 ] ; then
        REPOS_MOD="${REPOS_MOD} ${repo}"
    fi
    echo -e "\n----------------------------------------------------------------------------------"
    echo -e "----------------------------------------------------------------------------------\n"
done

if [ "x${REPOS_MOD}" = "x" ] ; then
    echo "All your repositories are clean"
else
    echo "The following repositories are not clean:"
    for i in $(echo ${REPOS_MOD}) ; do
        echo ${i}
    done
fi
exit 0

