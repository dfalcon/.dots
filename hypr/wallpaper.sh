#!/bin/sh
WP=$(find ~/Pictures/Wallpapers/linux -type f | shuf -n1)
pkill hyprpaper 2>/dev/null
pkill awww-daemon 2>/dev/null
sleep 0.5
awww-daemon &
sleep 1
awww img "$WP" --transition-type fade
