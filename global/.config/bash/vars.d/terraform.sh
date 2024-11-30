#!/usr/bin/env bash

if hash terraform ; then
    complete -C "$( which terraform )" terraform
fi
