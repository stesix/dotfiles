#!/usr/bin/env bash

function __copy() {
    if hash pbcopy &>/dev/null; then
        pbcopy
    elif hash wl-copy &>/dev/null; then
        wl-copy
    elif hash clip.exe &>/dev/null; then
        clip.exe
    elif hash xclip &>/dev/null; then
        xclip -selection clip
    else
        cat
        echo 2>/dev/null
        return
    fi
    echo >&2 "Copied!"
}
