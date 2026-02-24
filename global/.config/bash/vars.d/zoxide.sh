#!/usr/bin/env bash

if hash zoxide &>/dev/null; then
    eval "$(zoxide init bash --cmd cd)"
fi
