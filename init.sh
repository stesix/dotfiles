#!/bin/bash

MYPATH="$( dirname "$( realpath "$0" )" )"

function createLink {
    mkdir -p $( dirname ~/$1 )
    rm -rf 
    ln -s ${MYPATH}/$1 ~/$1
}

createLink '.bash.d'
createLink '.editorconfig'
createLink '.screenlayout'
createLink '.xkb'

ls ${MYPATH}/.config | while read f ; do
    createLink .config/$f
done
