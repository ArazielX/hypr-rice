#!/usr/bin/env python3
import sys
import json
import subprocess
import select
import html
import os
import traceback

# This ensures the script's output stream is configured for UTF-8
sys.stdout.reconfigure(encoding='utf-8')

# --- CONFIGURATION ---
cava_config_path = os.path.expanduser("~/.config/cava/config")
PLAYERCTL_CMD = [
    "stdbuf", "-oL", "playerctl", "-a", "metadata", "--format",
    '{"text": "{{artist}} - {{title}}", "class": "{{status}}"}', "-F"
]
CAVA_CMD = ["stdbuf", "-oL", "cava", "-p", cava_config_path]
# New, better-looking Unicode block characters for the visualizer
BARS = [" ", " ", "▂", "▃", "▄", "▅", "▆", "█"]
BAR_COUNT = 15
LOG_FILE = os.path.join(os.path.expanduser("~"), ".cache/waybar_media_script.log")

# --- COLORS ---
COLOR_PLAYING = "#66B2FF"
COLOR_PAUSED = "#FF0000"
COLOR_STOPPED = "#888888"
COLOR_VISUALIZER = "#66B2FF"

# --- GLOBAL STATE (Shared between functions) ---
player_text = ""
player_class = "Stopped"
cava_left = "".join([BARS[0]] * BAR_COUNT)
cava_right = "".join([BARS[0]] * BAR_COUNT)

# --- HELPER FUNCTIONS ---
def log_message(message):
    """Writes a message to the log file for debugging."""
    with open(LOG_FILE, "a") as f:
        f.write(f"[{os.getpid()}] {message}\n")

def escape(text):
    """Escapes text for Pango, including handling apostrophes."""
    return html.escape(text).replace("'", "&#39;")

def print_output():
    """Formats and prints the final Pango markup string for Waybar."""
    if "Playing" in player_class and player_text:
        icon = ""
        color = COLOR_PLAYING
        text_to_show = f"{icon}  {escape(player_text)}"
    elif "Paused" in player_class and player_text:
        icon = ""
        color = COLOR_PAUSED
        text_to_show = f"{icon} {escape(player_text)}"
    else: # Stopped or no player
        icon = ""
        color = COLOR_STOPPED
        text_to_show = icon

    if text_to_show and player_text:
        final_text = (
            f"<span color='{COLOR_VISUALIZER}'>{cava_left}</span> "
            f"<span color='{color}'>{text_to_show}</span> "
            f"<span color='{COLOR_VISUALIZER}'>{cava_right}</span>"
        )
    else:
        final_text = (
            f"<span color='{COLOR_VISUALIZER}'>{cava_left}</span> "
            f"<span color='{color}'>{icon}</span> "
            f"<span color='{COLOR_VISUALIZER}'>{cava_right}</span>"
        )

    # Print the raw Pango string directly to Waybar
    print(final_text, flush=True)

# --- MAIN PROCESS ---
def main():
    """Main process loop to listen to playerctl and cava."""
    global player_text, player_class, cava_left, cava_right

    try:
        player_proc = subprocess.Popen(PLAYERCTL_CMD, stdout=subprocess.PIPE, text=True, stderr=subprocess.DEVNULL)
        cava_proc = subprocess.Popen(CAVA_CMD, stdout=subprocess.PIPE, text=True, stderr=subprocess.DEVNULL)

        print_output()

        while True:
            rlist, _, _ = select.select([player_proc.stdout, cava_proc.stdout], [], [])

            for output in rlist:
                line = output.readline()
                if not line: continue
                line = line.strip()

                if output == player_proc.stdout:
                    try:
                        data = json.loads(line)
                        player_text = data.get("text", "")
                        player_class = data.get("class", "Stopped")
                    except json.JSONDecodeError: continue
                elif output == cava_proc.stdout:
                    values = [int(v) for v in line.split(";") if v.isdigit()]
                    if len(values) == BAR_COUNT * 2:
                        left_vals, right_vals = values[:BAR_COUNT], values[BAR_COUNT:]
                        cava_left = "".join(reversed([BARS[min(v, 7)] for v in left_vals]))
                        cava_right = "".join([BARS[min(v, 7)] for v in right_vals])

            print_output()

    except Exception as e:
        # Log any critical errors to the log file before exiting
        log_message(f"CRITICAL: Unhandled exception: {e}\n{traceback.format_exc()}")
        sys.exit(1)

if __name__ == "__main__":
    main()
