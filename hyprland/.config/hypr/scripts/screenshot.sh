#!/bin/bash
# Screenshot tool using grim + slurp

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y%m%d_%H%M%S).png"

case "$1" in
    --now)
        grim "$FILE" && wl-copy < "$FILE"
        notify-send -i "$FILE" "Screenshot saved" "$FILE"
        ;;
    --area)
        grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE"
        notify-send -i "$FILE" "Screenshot saved" "$FILE"
        ;;
    --active)
        local geom=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$geom" "$FILE" && wl-copy < "$FILE"
        notify-send -i "$FILE" "Screenshot saved" "$FILE"
        ;;
    --swappy)
        grim -g "$(slurp)" - | swappy -f -
        ;;
    --in5)
        sleep 5 && grim "$FILE" && wl-copy < "$FILE"
        notify-send -i "$FILE" "Screenshot saved" "$FILE"
        ;;
esac
