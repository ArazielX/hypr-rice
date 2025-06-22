#!/bin/bash

# --- CONFIGURATION ---
BARS=(" " "_" "-" "=" "≡" "#" "#" "#")
BAR_COUNT=7
COLOR_PLAYING="#66B2FF"
COLOR_PAUSED="#FF0000"
COLOR_STOPPED="#888888"
COLOR_VISUALIZER="#66B2FF"

# --- GET PLAYERCTL DATA ---
PLAYER_STATUS=$(playerctl status 2>/dev/null)
PLAYER_INFO=""
if [ "$PLAYER_STATUS" != "" ]; then
    PLAYER_INFO=$(playerctl metadata --format "{{artist}} - {{title}}")
fi

# --- GET CAVA DATA ---
# Read a single line of raw data from cava
CAVA_LINE=$(cava -p ~/.config/cava/config | head -n 1)

# Split the line into an array of values
IFS=';' read -ra CAVA_VALUES <<< "$CAVA_LINE"

# Format left bars (reversed)
LEFT_BARS=""
for i in $(seq 0 $((BAR_COUNT - 1))); do
    val=${CAVA_VALUES[$i]:-0}
    val=$((val > 7 ? 7 : val))
    LEFT_BARS="${BARS[$val]}$LEFT_BARS"
done

# Format right bars
RIGHT_BARS=""
for i in $(seq $BAR_COUNT $((BAR_COUNT * 2 - 1))); do
    val=${CAVA_VALUES[$i]:-0}
    val=$((val > 7 ? 7 : val))
    RIGHT_BARS="$RIGHT_BARS${BARS[$val]}"
done

# --- BUILD FINAL TEXT FOR WAYBAR ---
TEXT=""
# Escape for Pango
PLAYER_INFO_ESCAPED=$(echo "$PLAYER_INFO" | sed 's/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g;')

if [ "$PLAYER_STATUS" = "Playing" ]; then
    TEXT="<span color='${COLOR_PLAYING}'> ${PLAYER_INFO_ESCAPED}</span>"
elif [ "$PLAYER_STATUS" = "Paused" ]; then
    TEXT="<span color='${COLOR_PAUSED}'> ${PLAYER_INFO_ESCAPED}</span>"
else
    TEXT="<span color='${COLOR_STOPPED}'></span>"
fi

# Combine all parts
if [ "$PLAYER_INFO" != "" ]; then
    FINAL_TEXT="<span color='${COLOR_VISUALIZER}'>${LEFT_BARS}</span> ${TEXT} <span color='${COLOR_VISUALIZER}'>${RIGHT_BARS}</span>"
else
    FINAL_TEXT="<span color='${COLOR_VISUALIZER}'>${LEFT_BARS}${RIGHT_BARS}</span>"
fi

# --- JSON OUTPUT FOR WAYBAR ---
echo "{\"text\": \"${FINAL_TEXT}\"}"
