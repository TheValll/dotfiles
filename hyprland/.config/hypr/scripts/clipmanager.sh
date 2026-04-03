#!/bin/bash
# Clipboard manager with rofi

pkill rofi 2>/dev/null

selected=$(cliphist list | rofi -dmenu -p "Clipboard" -display-columns 2)

if [ -n "$selected" ]; then
    echo "$selected" | cliphist decode | wl-copy
fi
