#!/bin/bash
case "$1" in
    post)
        sleep 1
        systemctl --user -M dfalcon@ restart libinput-gestures
        ;;
esac
