#!/bin/bash

function print_git_status() {
    repo="$1"
    MSG="  GIT STATUS OF REPOSITORY ${repo}  "
    num_chars="$(echo "${MSG}" | wc -m)"
    num_side_hyphens=$(( (82 - ${num_chars} - 1) / 2))

    for i in $(seq 0 ${num_side_hyphens}) ; do
        echo -n "-"
    done

    echo -n "${MSG}"

    for i in $(seq 0 ${num_side_hyphens}) ; do
        echo -n "-"
    done
    echo ""

    git status

    echo -e "\n----------------------------------------------------------------------------------"
    echo -e "----------------------------------------------------------------------------------\n"
}

REPOS_PATH="${HOME}/repos"
for repo in $(ls ${REPOS_PATH}) ; do
    cd ${REPOS_PATH}/${repo}
    print_git_status "${repo}"
done
exit

