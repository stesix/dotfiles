#!/bin/bash

if [ $0 == "$BASH_SOURCE" ] ; then
    echo "Please source this script. Do not execute."
    exit 1
fi

BASHED_BASE_PATH="$( dirname "$( realpath $BASH_SOURCE )" )"

function getFileList {
    find "${BASHED_BASE_PATH}/vars.d" -type f -name "*.sh"
    find "${BASHED_BASE_PATH}/functions.d" -type f -name "*.sh"
    find "${BASHED_BASE_PATH}/autocomplete.d" -type f -name "*.sh"
}

source ${BASHED_BASE_PATH}/aliases.sh
if [ -f ~/.secrets/init.sh ] ; then
    source ~/.secrets/init.sh
fi

source bashlib

for file in $( getFileList ) ; do
    source $file
done

PS1="[${IRed}\!${NoColor}] ${IYellow}${USER}@${HOSTNAME}${NoColor}:${Cyan}\w ${IWhite}$ ${NoColor}"
