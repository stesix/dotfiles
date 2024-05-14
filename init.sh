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
    mkdir -p $( dirname ~/$1 )
    ln -s ${MYPATH}/$1 ~/$1
}

createLink '.bash.d'
createLink '.editorconfig'

if [ "$( uname -s )" != "Darwin" ] ; then
    createLink '.screenlayout'
    createLink '.xkb'
fi

git clone https://github.com/NvChad/NvChad ~/.config/nvim

ls ${MYPATH}/.config \
| while read f ; do
    createLink .config/$f
done
