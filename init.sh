#!/bin/bash

if [ "$( uname -s )" == "Darwin" ] && ! hash brew && ! hash realpath ; then
    if ! hash brew ; then
        echo "You need homebrew and coreutil"
        exit 1
    fi

    if ! hash realpath ; then
        echo "You need the coreutils"
        exit 1
    fi
fi


MYPATH="$( dirname "$( realpath "$0" )" )"

function createLink {
    local environment="$2"

    if [ -z "$environment" ] ; then
        echo "Missing environment in createLint call!"
        exit 1
    fi

    mkdir -p $( dirname ~/$1 )
    ln -s ${MYPATH}/${environment}/$1 ~/$1
}

function stowEnvironment {
    local environment="$1"

    ls -A "${MYPATH}/${environment}" | grep -v .config \
    | while read -r f ; do
        createLink "$f" "${environment}"
    done

    mkdir -p ~/.config
    ls -A "${MYPATH}/${environment}/.config" \
    | while read -r f ; do
        createLink ".config/$f" "${environment}"
    done
}

stowEnvironment 'global'

if [ "$( uname -s )" == "Darwin" ] ; then
    stowEnvironment 'osx'
fi

if [ "$( uname -s )" == "Linux" ] ; then
    stowEnvironment 'linux'
fi
