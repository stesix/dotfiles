#!/usr/bin/env bash

if [[ -n "${HOMEBREW_PREFIX}" ]] && [[ -f "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin/find" ]]; then
    # shellcheck disable=SC2139
    alias find=${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin/find
fi

if hash eza; then
    alias ls='eza'
    alias la='eza -A'
    alias ll='eza --git --icons --octal-permissions --long --header --no-user --no-permissions --all'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
fi

if hash atuin; then
    alias as='atuin script'
    alias asr='atuin script run'
    alias asl='atuin script list'
fi

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if ! hash pbcopy 2>/dev/null; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
fi

if hash nvim; then
    alias vim='nvim'
fi

alias mkctl='microk8s kubectl'
alias docker-compose='docker compose'
alias tf='terraform'
alias stripcolors='sed "s/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g"'

# Git specific
alias git_most_changed='git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -30'
alias git_who_did_it='git shortlog -sn --no-merges --since="1 year ago"'
alias git_bug_clusters='git log -i -E --grep="fix|bug|broken" --name-only --format="" | sort | uniq -c | sort -nr | head -30'
alias git_speed="git log --format='%ad' --date=format:'%Y-%m' | sort -nr | uniq -c"
