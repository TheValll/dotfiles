#!/bin/bash
# Screen brightness control with notifications

step=5

notify() {
    local val=$(brightnessctl -m | cut -d, -f4 | tr -d %)
    notify-send -h int:value:"$val" -h string:x-canonical-private-synchronous:brightness \
        -i display-brightness "Brightness: ${val}%"
}

case "$1" in
    --inc) brightnessctl set +${step}% && notify ;;
    --dec) brightnessctl set ${step}%- && notify ;;
esac
