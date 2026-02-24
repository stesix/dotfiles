#!/usr/bin/env bash

if hash starship &>/dev/null; then
    export STARSHIP_CONFIG=~/.config/starship/starship.toml
    eval "$(starship init bash)"
fi
