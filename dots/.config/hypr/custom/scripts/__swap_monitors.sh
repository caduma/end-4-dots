#!/bin/bash

monitors=$(hyprctl monitors -j)
count=$(jq length <<< $monitors)

if [ $count -ne 2 ]; then
    echo "This only works when two monitors are active!"
    exit
fi

ws_a=$(echo "$monitors" | jq -r '.[0].activeWorkspace.id')
mon_a=$(echo "$monitors" | jq -r '.[0].name')

ws_b=$(echo "$monitors" | jq -r '.[1].activeWorkspace.id')
mon_b=$(echo "$monitors" | jq -r '.[1].name')

hyprctl dispatch moveworkspacetomonitor "$ws_a" "$mon_b"
hyprctl dispatch moveworkspacetomonitor "$ws_b" "$mon_a"

hyprctl dispatch workspace "$ws_a"
hyprctl dispatch workspace "$ws_b"

hyprctl dispatch togglefullscreen 1
hyprctl dispatch togglefullscreen 0

hyprctl dispatch swapactiveworkspaces