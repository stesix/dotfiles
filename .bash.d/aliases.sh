#!/bin/bash

if hash eza ; then
    alias ls='eza'
    alias ll='eza --git --icons --octal-permissions --long --header --no-user --no-permissions --all'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
fi

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if ! hash pbcopy 2> /dev/null ; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
fi

if hash nvim ; then
    alias vim='nvim'
fi

alias mkctl='microk8s kubectl'
alias docker-compose='docker compose'
