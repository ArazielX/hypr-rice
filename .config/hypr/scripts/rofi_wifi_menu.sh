#!/usr/bin/env bash

# Rofi Wi-Fi Menu - Final Corrected Version

# Get a list of only REAL Wi-Fi interfaces
wifi_interfaces=$(nmcli device status | grep 'wifi ' | grep -v 'p2p' | awk '{print $1}')

all_networks=""

for interface in $wifi_interfaces; do
    # Get networks for the current interface
    networks=$(nmcli --terse --fields "SSID,SECURITY,BARS" device wifi list ifname "$interface" | grep -v "^--")

    while read -r line; do
        ssid=$(echo "$line" | cut -d':' -f1)
        security=$(echo "$line" | cut -d':' -f2)
        bars=$(echo "$line" | cut -d':' -f3)

        if [ -z "$ssid" ]; then
            continue
        fi

        # Add the network to our list for Rofi
        all_networks+="$ssid:$interface:$security:$bars\n"
    done <<< "$networks"
done

# Use Rofi to select a network. We pass the full info separated by colons.
chosen_network_line=$(echo -e "$all_networks" | \
    awk -F: '{printf " [%-5s] %-20s (%s)\n", $2, $1, $4}' | \
    sort -u | rofi -dmenu -i -p "Wi-Fi" -theme ~/.config/rofi/theme.rasi)

# Exit if nothing is chosen
if [ -z "$chosen_network_line" ]; then
    exit 0
fi

# Extract the pure SSID and interface from the Rofi output
chosen_interface=$(echo "$chosen_network_line" | awk -F'[][]' '{print $2}')
chosen_ssid=$(echo "$chosen_network_line" | sed 's/.. \[[^]]*\] //' | awk '{$NF="";print $0}' | sed 's/ *$//')

# Connect to the chosen network using the correct interface
if nmcli connection show | grep -q "^$chosen_ssid\s"; then
    nmcli connection up "$chosen_ssid"
else
    wifi_password=$(rofi -dmenu -p "Password for $chosen_ssid" -password -theme ~/.config/rofi/theme.rasi)
    if [ -n "$wifi_password" ]; then
        nmcli device wifi connect "$chosen_ssid" password "$wifi_password" ifname "$chosen_interface"
    fi
fi
