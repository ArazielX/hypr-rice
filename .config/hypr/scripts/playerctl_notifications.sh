#!/bin/bash

# Final notification script using song title for detection

last_title=""

while true; do
    player_status=$(playerctl status 2>/dev/null)

    if [[ "$player_status" == "Playing" || "$player_status" == "Paused" ]]; then
        # Get the current song title
        current_title=$(playerctl metadata title)

        # Check if the title exists and has changed
        if [ -n "$current_title" ] && [ "$current_title" != "$last_title" ]; then
            # Send notification
            notify-send "Now Playing" "$(playerctl metadata artist) - $current_title" --icon=media-tape

            # Update the last known title
            last_title=$current_title
        fi
    else
        # No player is running, reset the last title
        last_title=""
    fi

    sleep 2
done
