#!/bin/bash

MYPATH="$( dirname "$( realpath "$0" )" )"

function createLink {
    mkdir -p $( dirname ~/$1 )
    ln -s ${MYPATH}/$1 ~/$1
}

createLink '.bash.d'
createLink '.editorconfig'
createLink '.screenlayout'
createLink '.xkb'

ls ${MYPATH}/.config | while read f ; do
    createLink .config/$f
done

mkdir ~/.config/nvim/bundle
git clone  git clone https://github.com/VundleVim/Vundle.vim.git ~/.config/nvim/bundle/Vundle.vim
