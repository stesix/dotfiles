#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

exec > ${SCRIPT_DIR}/identities.inc

cat <<EOT
###   This file is generated by the .config/git/build.sh any changes are going to be lost
###    at the next execution.

EOT

find ~/repos.* -maxdepth 1 -name .gitconfig | while read -r file ; do
    file="${file//${HOME}/}"
    repos_path="${file%.gitconfig}"
    echo '[includeIf "gitdir:~'"${repos_path}"'"]'
    echo '      path = "~'"${file}"'"'
    echo ''
done
