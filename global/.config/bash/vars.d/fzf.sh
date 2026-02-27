#!/usr/bin/env bash

if hash fzf &>/dev/null; then
    bind -x '"\t": fzf_bash_completion'
fi
