#!/bin/bash
# Kill the active window's process

kill $(hyprctl activewindow -j | jq '.pid')
