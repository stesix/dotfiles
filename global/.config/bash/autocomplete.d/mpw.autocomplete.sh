#!/usr/bin/env bash

# MPW Autocomplete
export MPW_ENTRIES_PATH

if which mpw &>/dev/null; then
    MPW_ENTRIES_PATH="$HOME/.mpw.d/$MPW_FULLNAME"
elif which spectre &>/dev/null; then
    MPW_ENTRIES_PATH="$HOME/.spectre.d/$MPW_FULLNAME"
fi

__mpw_entries() {
    local cur
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    local items
    items=$(jq '.sites | to_entries | .[] .key' "$MPW_ENTRIES_PATH"*.*json | sort -u | sed 's/"//g')
    mapfile -t COMPREPLY < <(compgen -W "$items" "$cur")
}

complete -F __mpw_entries mpw spectre
