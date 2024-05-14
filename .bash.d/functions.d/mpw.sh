#!/bin/bash

mpw_cmd=''
if which mpw &>/dev/null ; then
    mpw_cmd="$( which mpw )"
elif which spectre &>/dev/null ; then
    mpw_cmd="$( which spectre )"
fi

mpw() {
    # Empty the clipboard
    :| __copy 2>/dev/null

    MPW_FULLNAME=${MPW_FULLNAME:-$(ask 'Your Full Name:')}
    SPECTRE_USERNAME="${MPW_FULLNAME}"

    printf %s "$(MPW_FULLNAME=$MPW_FULLNAME SPECTRE_USERNAME="${SPECTRE_USERNAME}" command ${mpw_cmd} "$@")" | __copy
}
