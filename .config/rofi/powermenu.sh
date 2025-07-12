#!/bin/bash

# Rofi Power Menu - Final Working Version (handles spacing issues)

shutdown="   Shutdown\0meta\x1fbutton-shutdown"
logout="󰍃   Logout\0meta\x1fbutton-logout"
reboot="   Reboot\0meta\x1fbutton-reboot"
lock="   Lock\0meta\x1fbutton-lock"

chosen_option=$(echo -e "$shutdown\n$logout\n$reboot\n$lock" | rofi -dmenu \
    -theme ~/.config/rofi/powermenu_grid.rasi \
    -p "" \
    -hide-scrollbar \
    -no-custom \
    -format s)

# Trim whitespace from the result
chosen_option=$(echo "$chosen_option" | xargs)

# Debug (optional)
# echo "Chosen: '$chosen_option'"

case "$chosen_option" in
    " Shutdown")
        systemctl poweroff
        ;;
    "󰍃 Logout")
        hyprctl dispatch exit
        ;;
    " Reboot")
        systemctl reboot
        ;;
    " Lock")
        hyprlock
        ;;
esac
