#!/usr/bin/env bash

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    echo "Please source this script. Do not execute."
    exit 1
fi

if [[ -z "$HOMEBREW_PREFIX" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -n "$HOMEBREW_PREFIX" ]]; then
    #    [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]] && . "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"

    [[ -d "${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin" ]] && PATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"
    [[ -d "${HOMEBREW_PREFIX}/opt/gnu-which/libexec/gnubin" ]] && PATH="${HOMEBREW_PREFIX}/opt/gnu-which/libexec/gnubin:$PATH"
    [[ -d "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin:$PATH" ]] && PATH="${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin:$PATH"
    [[ -d "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin" ]] && PATH="${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin:$PATH"
    [[ -d "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin" ]] && PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"
    [[ -d "${HOMEBREW_PREFIX}/opt/gawk/libexec/gnubin" ]] && PATH="${HOMEBREW_PREFIX}/opt/gawk/libexec/gnubin:$PATH"
    [[ -d "${HOMEBREW_PREFIX}/opt/make/libexec/gnubin" ]] && PATH="${HOMEBREW_PREFIX}/opt/make/libexec/gnubin:$PATH"

    [[ -r "${HOMEBREW_PREFIX}/etc/bash_completion.d/brew" ]] && source "${HOMEBREW_PREFIX}/etc/bash_completion.d/brew"
    [[ -r "${HOMEBREW_PREFIX}/etc/bash_completion.d/google-cloud-sdk" ]] && source "${HOMEBREW_PREFIX}/etc/bash_completion.d/google-cloud-sdk"
fi

BASHED_BASE_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

function getFileList() {
    find "${BASHED_BASE_PATH}/vars.d" -type f -name "*.sh" -o -name "*.bash" | sort
    find "${BASHED_BASE_PATH}/functions.d" -type f -name "*.sh" -o -name "*.bash" | sort
    find "${BASHED_BASE_PATH}/autocomplete.d" -type f -name "*.sh" -o -name "*.bash" | sort
}

export BAT_THEME='Catppuccin Mocha'
export EDITOR=nvim

source "${BASHED_BASE_PATH}/aliases.sh"

# shellcheck disable=SC1090
for file in $(getFileList); do
    source "$file"
done
