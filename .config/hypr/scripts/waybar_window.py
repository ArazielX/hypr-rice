#!/usr/bin/env python3

import json
import os
import socket
import sys
import html
import subprocess
import traceback

# --- Functions ---

def get_title():
    """Gets the active window title and class."""
    try:
        hyprctl_cmd = "/usr/bin/hyprctl"
        result = subprocess.run([hyprctl_cmd, "activewindow", "-j"], capture_output=True, text=True, check=True)
        window_info = json.loads(result.stdout)
        title = window_info.get("title", "")
        window_class = window_info.get("class", "")
        return title, window_class
    except Exception:
        return "", ""

def print_formatted_title(title, window_class):
    """Formats and prints the title for Waybar."""
    red = "#F44336"
    blue = "#00A3FF"

    if not title or title == "null":
        text = ""  # Placeholder icon
    elif "Brave" in window_class and " - Brave" in title:
        parts = title.rsplit(" - ", 1)
        main_title = parts[0]
        browser_part = html.escape(parts[1])

        # This is the new truncation logic
        max_len = 15
        if len(main_title) > max_len:
            truncated_title = main_title[:max_len] + "..."
        else:
            truncated_title = main_title

        escaped_title = html.escape(truncated_title)

        text = f"<span color='{red}'>{escaped_title}</span> - <span color='{blue}'>{browser_part}</span>"
    else:
        text = html.escape(title)

    # Print the raw Pango string directly, which is our workaround for the Waybar bug
    print(text, flush=True)

# --- Main Loop ---

def main():
    """Main function to listen for events."""
    try:
        instance_signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
        runtime_dir = os.environ.get("XDG_RUNTIME_DIR")

        if not instance_signature or not runtime_dir:
            sys.exit(1)

        sock_path = f"{runtime_dir}/hypr/{instance_signature}/.socket2.sock"

        # Initial print
        title, window_class = get_title()
        print_formatted_title(title, window_class)

        # Connect to Hyprland event socket
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(sock_path)

        # Listen for events
        while True:
            data = sock.recv(4096).decode("utf-8")
            for line in data.strip().split("\n"):
                if line.startswith("activewindow>>"):
                    title, window_class = get_title()
                    print_formatted_title(title, window_class)
    except Exception:
        sys.exit(1)

if __name__ == "__main__":
    main()
