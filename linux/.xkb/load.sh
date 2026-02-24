#!/usr/bin/env bash

export DISPLAY=${DISPLAY:-:0}

xhost local:root

setxkbmap \
    -layout us,it,de \
    -variant intl-unicode,,qwerty \
    -option 'grp:shifts_toggle' \
    -option 'altwin:swap_lalt_lwin' \
    -option 'caps:ctrl_modifier' \
    -option 'lv5:rwin_switch_lock'

xkbcomp -w0 -I$HOME/.xkb $HOME/.xkb/keymap/mykbd $DISPLAY
