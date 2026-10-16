#!/bin/bash
entries="Study\nShowoff\nEverforestlight\nTokyonight"
HYPRLAND="$HOME/.config/hypr/hyprland.lua"
selected=$(echo -e "$entries" | rofi -dmenu -i -p "Theme")
[ -z "$selected" ] && exit 0
theme=$(echo "$selected" | tr '[:upper:]' '[:lower:]')
sed -i "s/^CURRENT_THEME = .*/CURRENT_THEME = \"$theme\"/" "$HYPRLAND"
notify-send "Theme Changed" "$selected"
pkill -x qs
pkill -x waybar
sleep 0.3
hyprctl reload
