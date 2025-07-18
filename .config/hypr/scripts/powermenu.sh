#!/bin/bash

# Rofi Power Menu - Final Version with Title and No Input Bar

# Set message title for rofi
export ROFI_MESSAGE="Power Menu"

# Define menu options with icon and class metadata
shutdown="   Shutdown\0meta\x1fbutton-shutdown"
logout="󰍃   Logout\0meta\x1fbutton-logout"
reboot="   Reboot\0meta\x1fbutton-reboot"
lock="   Lock\0meta\x1fbutton-lock"

# Launch Rofi with custom theme and no search bar
chosen_option=$(echo -e "$shutdown\n$logout\n$reboot\n$lock" | rofi -dmenu \
    -theme ~/.config/rofi/powermenu_grid.rasi \
    -p "" \
    -hide-scrollbar \
    -no-custom \
    -format s)

# Act on user choice
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
