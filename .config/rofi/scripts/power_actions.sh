#!/bin/bash

# Array of menu entries and their corresponding icon filenames
entries=(
    "Lock\x00icon\x1f$HOME/.config/rofi/icons/lock.png"
    "Logout\x00icon\x1f$HOME/.config/rofi/icons/logout.png"
    "Shutdown\x00icon\x1f$HOME/.config/rofi/icons/shutdown.png"
    "Reboot\x00icon\x1f$HOME/.config/rofi/icons/reboot.png"
)

# Show the menu and get the choice
choice=$(printf "%s\n" "${entries[@]}" | rofi-wayland -dmenu -markup-rows -theme "$HOME/.config/rofi/themes/_grid.rasi" -p "Power Menu" | cut -d' ' -f1)

case "$choice" in
    Lock) loginctl lock-session ;;
    Logout) hyprctl dispatch exit ;;
    Shutdown) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
esac
