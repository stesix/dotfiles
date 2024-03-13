#!/bin/bash

alias ls='ls --color=auto'
alias ll='ls -alF'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if ! hash pbcopy 2> /dev/null ; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
fi

alias i3config='vim ~/.config/i3/config'
alias i3blockconfig='vim ~/.config/i3blocks/config'

alias sshconfig='vim ~/.ssh/config'
