#!/usr/bin/env bash

if [[ "$(uname -s)" == "Darwin" ]]; then
    function good_morning_bitch {
        local bmad_version exit_code
        local DATA_DIR="${XDG_DATA_HOME}/good_morning_bitch"
        local bmad_version_file="${DATA_DIR}/bmad_version.txt"

        mkdir -p "$DATA_DIR"

        brew bundle -g \
            --upgrade \
            --cleanup \
            --quiet

        # Upgrade neovim plugins and LSP
        nvim --headless "+Lazy update" "+MasonUpdate" "+qa"
        echo ""

        bmad_version="$(basename "$(curl -s https://github.com/bmad-code-org/BMAD-METHOD/releases/ | grep -o '[^"]*BMAD-METHOD/releases/tag[^"]*' | head -1)")"
        exit_code=$?

        if [[ $exit_code -gt 0 ]]; then
            echo "Something went wrong while checking bmad version"
            return 1
        fi

        echo "$bmad_version" >$bmad_version_file

        if [[ ! -r "${bmad_version_file}.old" ]] || ! diff -qqq "$bmad_version_file" "${bmad_version_file}.old"; then
            echo "###############################################################################"
            echo "# A new BMAD version ($bmad_version) is now available."
            echo "###############################################################################"
            echo ''
            cp "$bmad_version_file" "${bmad_version_file}.old" &>/dev/null
        fi
    }
fi
