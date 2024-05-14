#!/bin/sh

xrandr \
    --output eDP-1-1 --mode 1920x1080 --pos 1680x0 --rotate normal \
    --output HDMI-0 --mode 1680x1050 --pos 0x0 --rotate normal \
    --output DP-1 --off \
    --output DP-0 --off
