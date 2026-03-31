#!/usr/bin/env bash

TARGET_WS=$1
MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')

hyprctl dispatch moveworkspacetomonitor "$TARGET_WS $MONITOR"
hyprctl dispatch workspace "$TARGET_WS"