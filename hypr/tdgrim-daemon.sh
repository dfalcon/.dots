#!/bin/bash
# Pre-captures Wayland screen for Time Doctor XGetImage intercept
OUTPNG=/tmp/.tdgrim_latest.png
while true; do
    grim -t png "$OUTPNG" 2>/dev/null
    sleep 15
done
