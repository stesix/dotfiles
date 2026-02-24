#!/usr/bin/env bash

if hash opencode &>/dev/null; then
    export OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT=true
    export OPENCODE_EXPERIMENTAL_EXA=true
fi
