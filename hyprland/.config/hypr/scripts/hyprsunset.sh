#!/bin/bash
# Night light toggle with state persistence

STATE_FILE="$HOME/.cache/.hyprsunset_state"
TEMP=3500

case "$1" in
    toggle)
        if pgrep -x hyprsunset > /dev/null; then
            pkill hyprsunset
            echo "off" > "$STATE_FILE"
            notify-send -i weather-clear "Night light off"
        else
            nohup hyprsunset -t $TEMP > /dev/null 2>&1 &
            echo "on" > "$STATE_FILE"
            notify-send -i weather-clear-night "Night light on (${TEMP}K)"
        fi
        ;;
    init)
        if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "on" ]; then
            nohup hyprsunset -t $TEMP > /dev/null 2>&1 &
        fi
        ;;
    status)
        if pgrep -x hyprsunset > /dev/null; then
            echo '{"text": "󰌵", "class": "on", "tooltip": "Night light on"}'
        else
            echo '{"text": "󰌶", "class": "off", "tooltip": "Night light off"}'
        fi
        ;;
esac
