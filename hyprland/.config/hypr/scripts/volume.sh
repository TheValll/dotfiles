#!/bin/bash
# Volume control with notifications

step=5

get_icon() {
    local vol=$1 muted=$2
    if [ "$muted" = "true" ]; then echo "audio-volume-muted"; return; fi
    if [ "$vol" -ge 66 ]; then echo "audio-volume-high"
    elif [ "$vol" -ge 33 ]; then echo "audio-volume-medium"
    elif [ "$vol" -ge 1 ]; then echo "audio-volume-low"
    else echo "audio-volume-muted"; fi
}

notify() {
    local vol=$(pamixer --get-volume)
    local muted=$(pamixer --get-mute)
    notify-send -h int:value:"$vol" -h string:x-canonical-private-synchronous:volume \
        -i "$(get_icon $vol $muted)" "Volume: ${vol}%"
}

case "$1" in
    --inc) pamixer -i $step && notify ;;
    --dec) pamixer -d $step && notify ;;
    --toggle) pamixer -t && notify ;;
    --toggle-mic) pamixer --default-source -t && notify-send -i audio-input-microphone "Mic toggled" ;;
esac
