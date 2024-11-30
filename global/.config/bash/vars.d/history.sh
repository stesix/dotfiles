#!/bin/bash

# Append history instead of rewriting it
shopt -s histappend

# Allow a larger history file
HISTFILESIZE=1000000
HISTSIZE=1000000

# Don’t store commands starting with a space or duplicates
HISTCONTROL=ignoreboth

# Don't store ls,ll,bg,fg or history commands
HISTIGNORE='ls:ll:bg:fg:history'

# Record timestamps
HISTTIMEFORMAT='%F %T '

# Use one command per line
shopt -s cmdhist

# Store history immediately
PROMPT_COMMAND='history -a'
