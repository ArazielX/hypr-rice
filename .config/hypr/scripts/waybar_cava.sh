#!/bin/bash

# This script reads stereo raw data from cava and formats it for Waybar.
# It takes one argument: "left" or "right" to determine which channel to display.

# Define the bar characters from empty to full
bar=(" " "▂" "▃" "▄" "▅" "▆" "▇" "█")
bar_count=25 # Number of bars for each channel (left/right)

# Read cava's raw output line by line
cava -p ~/.config/cava/config | while read -r line; do
    output=""
    # Split the stereo line into an array
    IFS=';' read -ra values <<< "$line"

    # Depending on the script argument, process the correct half of the values
    if [ "$1" == "left" ]; then
        # Process the first half for the left visualizer
        for i in $(seq 0 $((bar_count - 1))); do
            index=${values[$i]:-0} # Default to 0 if value is missing
            index=$((index < 0 ? 0 : index))
            index=$((index > 7 ? 7 : index))
            # Build the output string for the left side, but reversed
            output="${bar[$index]}$output"
        done
    elif [ "$1" == "right" ]; then
        # Process the second half for the right visualizer
        for i in $(seq $bar_count $((bar_count * 2 - 1))); do
            index=${values[$i]:-0} # Default to 0 if value is missing
            index=$((index < 0 ? 0 : index))
            index=$((index > 7 ? 7 : index))
            output+="${bar[$index]}"
        done
    fi

    # Print the final string in Waybar's JSON format.
    echo "{\"text\": \"$output\", \"tooltip\": \"Audio Visualizer\"}"
done
