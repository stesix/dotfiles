#!/bin/bash

__copy() {
    if hash pbcopy 2>/dev/null; then
        pbcopy
    elif hash clip.exe 2>/dev/null; then
        clip.exe
    elif hash xclip 2>/dev/null; then
        xclip -selection clip
    else
        cat; echo 2>/dev/null
        return
    fi
    echo >&2 "Copied!"
}
