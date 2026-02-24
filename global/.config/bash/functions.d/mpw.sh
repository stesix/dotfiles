#!/usr/bin/env bash

mpw_cmd=''
if command -v mpw &>/dev/null; then
    mpw_cmd="$(command -v mpw)"
elif command -v spectre &>/dev/null; then
    mpw_cmd="$(command -v spectre)"
fi

function mpw() {
    # Empty the clipboard
    : | __copy 2>/dev/null

    MPW_FULLNAME=${MPW_FULLNAME:-$(ask 'Your Full Name:')}
    SPECTRE_USERNAME="${MPW_FULLNAME}"

    printf %s "$(MPW_FULLNAME=$MPW_FULLNAME SPECTRE_USERNAME="${SPECTRE_USERNAME}" command ${mpw_cmd} "$@")" | __copy
}
