#!/bin/bash

# --- Rofi Power Menu ---

# Options presented in the menu
shutdown=" Shutdown"
reboot=" Reboot"
lock=" Lock"
logout="󰍃 Logout"

# Function to display the Rofi menu
show_menu() {
    echo -e "$shutdown\n$reboot\n$lock\n$logout" | rofi -dmenu -p "Power Menu" -theme ~/.config/rofi/theme.rasi
}

# Get the user's choice
chosen_option=$(show_menu)

# Execute the command based on the choice
case "$chosen_option" in
    "$shutdown")
        systemctl poweroff
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$lock")
        hyprlock
        ;;
    "$logout")
        hyprctl dispatch exit
        ;;
esac
