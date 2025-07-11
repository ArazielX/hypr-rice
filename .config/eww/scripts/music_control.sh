#!/bin/bash

# Eww music control script

sleep 5 # Wait 5 seconds for players to start

# This command listens for any change in player metadata
playerctl --follow metadata --format '{{mpris:trackid}}' | while read -r trackid; do

    # When a change is detected, fetch all metadata at once
    art_url=$(playerctl metadata mpris:artUrl)
    title=$(playerctl metadata xesam:title)
    artist=$(playerctl metadata xesam:artist)
    album=$(playerctl metadata xesam:album)

    # Update the Eww variables we defined in eww.yuck
    eww update album_art_path="$art_url"
    eww update song_title="$title"
    eww update song_artist="$artist"
    eww update song_album="$album"

    # Open the notification window
    eww open music_notification

    # Wait 5 seconds, then close it
    sleep 5
    eww close music_notification
done
