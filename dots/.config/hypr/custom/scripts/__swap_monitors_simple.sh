#!/bin/bash

monitors=$(hyprctl monitors -j)
count=$(jq length <<< $monitors)

if [ $count -ne 2 ]; then
    echo "This only works when two monitors are active!"
    exit
fi

hyprctl dispatch swapactiveworkspaces 1 0