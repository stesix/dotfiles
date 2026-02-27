#!/usr/bin/env bash

#################### Instruction for profiling bash starting process
# mkdir -p ~/bash_profiling.d
# PS4='+ $EPOCHREALTIME\011 '
# exec 3>&2 2> ~/bash_profiling.d/bashstart.$EPOCHSECONDS.log
# set -x
#################### Instruction for profiling bash starting process

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export PATH="$PATH:$HOME/.local/bin"

[[ -s "$HOME/.jabba/jabba.sh" ]] && source "$HOME/.jabba/jabba.sh"
[[ -r ~/.config/bash/source.sh ]] && source ~/.config/bash/source.sh

#################### Use this when profiling bash starting process
# set +x
# exec 2>&3 3>&-
#################### Use this when profiling bash starting process
