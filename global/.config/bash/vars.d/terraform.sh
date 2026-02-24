#!/usr/bin/env bash

if hash terraform &>/dev/null; then
    complete -C "$(which terraform)" terraform
fi
