#!/bin/bash

if hyprctl monitors | grep -q "DP-1"; then
    hyprctl keyword monitor HDMI-A-1, 1920x1080@60, 0x0, 1
    hyprctl keyword monitor DP-1, disable
    hyprctl keyword general:col.active_border "rgba(00ff00ff) 45deg"
    sleep 0.2
    hyprctl keyword general:col.active_border "rgba(ff0055ee) rgba(00ff55ee) 45deg"
else
    hyprctl keyword monitor HDMI-A-1, 1920x1080@60, 0x0, 1
    hyprctl keyword monitor DP-1, 2560x1440, 1920x0, 1, vrr, 0
    hyprctl keyword general:col.active_border "rgba(00ff00ff) 45deg"
    sleep 0.2
    hyprctl keyword general:col.active_border "rgba(ff0055ee) rgba(00ff55ee) 45deg"
fi