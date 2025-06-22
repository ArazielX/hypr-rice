#!/usr/bin/env bash

# Rofi Wi-Fi Menu using nmcli

# Function to show the menu of available networks
show_menu() {
    nmcli --fields IN-USE,SSID,SECURITY,BARS device wifi list | sed '/^--/d' | sed 's/IN-USE\s//' | sed 's/SSID\s//' | sed 's/SECURITY\s//' | sed 's/BARS\s//' | sed 's/--/ Not Connected/' | rofi -dmenu -p "Wi-Fi" -mesg "Select a network to connect" -theme ~/.config/rofi/theme.rasi
}

# Main logic
chosen_network_line=$(show_menu)

# Exit if nothing is selected
if [ -z "$chosen_network_line" ]; then
    exit 0
fi

# Get the connection status and SSID
connection_status=$(echo "$chosen_network_line" | awk '{print $1}')
chosen_essid=$(echo "$chosen_network_line" | awk '{$1=""; print $0}' | sed 's/^ *//')

# If already connected, do nothing
if [ "$connection_status" = "*" ]; then
    exit 0
fi

# Check if a connection profile for this network already exists
if nmcli connection show | grep -q "$chosen_essid"; then
    # If it exists, just bring the connection up
    nmcli connection up "$chosen_essid"
else
    # If it's a new network, ask for a password
    wifi_password=$(rofi -dmenu -p "Password for $chosen_essid" -password -theme ~/.config/rofi/theme.rasi)

    # If a password was entered, try to connect
    if [ -n "$wifi_password" ]; then
        nmcli device wifi connect "$chosen_essid" password "$wifi_password"
    fi
fi
