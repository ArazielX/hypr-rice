#!/bin/bash

# Define absolute paths to ensure commands are found
HYPRCTL_CMD="/usr/bin/hyprctl"
JQ_CMD="/usr/bin/jq"

# Get the title using the robust JSON method
full_title=$($HYPRCTL_CMD activewindow -j | $JQ_CMD -r .title)

# Check for empty or "null" title and show placeholder
if [ -z "$full_title" ] || [ "$full_title" == "null" ]; then
    echo "{\"text\": \"\", \"tooltip\": \"Desktop\"}"
    exit 0
fi

# Function to escape text for Pango markup
escape_pango() {
    echo "$1" | sed 's/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g;'
}

# Define colors
red="#F44336"
blue="#00A3FF"

# Default text is the escaped title
text=$(escape_pango "$full_title")

# Logic to colorize Brave titles
if [[ $full_title == *" - Brave"* ]]; then
    part1=$(echo "$full_title" | awk -F ' - ' '{print $1}')
    part2=$(echo "$full_title" | awk -F ' - ' '{print $2}')

    part1_escaped=$(escape_pango "$part1")
    part2_escaped=$(escape_pango "$part2")

    # Use single quotes for Pango attributes
    text="<span color='${red}'>${part1_escaped}</span> - <span color='${blue}'>${part2_escaped}</span>"
fi

# JSON escape for tooltip
tooltip=$(echo "$full_title" | sed 's/"/\\"/g')

# Final JSON output
echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\"}"
