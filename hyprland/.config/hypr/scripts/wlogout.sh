#!/bin/bash
# Launch wlogout with DPI-aware margins

if pgrep -x wlogout > /dev/null; then
    pkill wlogout
    exit 0
fi

# Get focused monitor scale
scale=$(hyprctl -j monitors | jq '.[] | select(.focused) | .scale')
height=$(hyprctl -j monitors | jq '.[] | select(.focused) | .height')

# Calculate margins (roughly 30% top/bottom)
margin=$(echo "$height $scale" | awk '{printf "%d", ($1 / $2) * 0.3}')

wlogout -b 5 -T "$margin" -B "$margin" --protocol layer-shell &
