#!/usr/bin/env bash

if hash zoxide ; then
    eval "$( zoxide init bash --cmd cd )"
fi
