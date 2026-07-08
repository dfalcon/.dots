#!/bin/bash
# Intercepts Time Doctor blank screenshots and replaces with real grim capture
TD_DIR="$HOME/.config/Time Doctor/local"
mkdir -p "$TD_DIR"

inotifywait -m "$TD_DIR" -e create --format '%f' 2>/dev/null | while read filename; do
    filepath="$TD_DIR/$filename"
    # Take real screenshot immediately
    grim -t jpeg -q 85 "$filepath"
done
