#!/usr/bin/env bash

if [[ "$(uname -s)" == "Darwin" ]] && ! hash brew && ! hash realpath; then
    if ! hash brew; then
        echo "You need homebrew and coreutil"
        exit 1
    fi

    if ! hash realpath; then
        echo "You need the coreutils"
        exit 1
    fi
fi

MYPATH="$(dirname "$(realpath "$0")")"

function createLink() {
    local environment="$2"

    if [[ -z "$environment" ]]; then
        echo "Missing environment in createLink call!"
        exit 1
    fi

    mkdir -p "$(dirname ~/"$1")"
    ln -s "${MYPATH}/${environment}/$1" ~/"$1"
}

function stowEnvironment() {
    local environment="$1"

    for f in "${MYPATH}/${environment}/"*; do
        # skip .config directory
        [[ "$(basename "$f")" == .config ]] && continue
        # skip if no files match
        [[ -e "$f" ]] || continue
        createLink "$(basename "$f")" "${environment}"
    done

    mkdir -p ~/.config
    for f in "${MYPATH}/${environment}/.config/"*; do
        # skip if no files match
        [[ -e "$f" ]] || continue
        createLink ".config/$(basename "$f")" "${environment}"
    done
}

stowEnvironment 'global'

if [[ "$(uname -s)" == "Darwin" ]]; then
    stowEnvironment 'osx'
fi

if [[ "$(uname -s)" == "Linux" ]]; then
    stowEnvironment 'linux'
fi
