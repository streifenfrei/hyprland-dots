#!/bin/bash

# Simple Wayland screenshot & recording tool for Hyprland

CHOICE=$(printf "Fullscreen Screenshot\n Region Screenshot\n Start Recording\n Stop Recording" | tofi --prompt "Select action:" --font /usr/share/fonts/gnu-free/FreeSans.otf)

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

case "$CHOICE" in
  "Fullscreen Screenshot")
    grim "$HOME/Pictures/Screenshot_Full_$TIMESTAMP.png" \
      && notify-send "Fullscreen screenshot saved" "$HOME/Pictures/Screenshot_Full_$TIMESTAMP.png"
    ;;

  "Region Screenshot")
    REGION=$(slurp)
    if [ -n "$REGION" ]; then
      grim -g "$REGION" "$HOME/Pictures/Screenshot_$TIMESTAMP.png"
      notify-send "Region screenshot saved" "$HOME/Pictures/Screenshot_$TIMESTAMP.png"
    else
      notify-send "Screenshot cancelled"
    fi
    ;;

  "Start Recording")
    pkill wf-recorder 2>/dev/null
    notify-send "Recording started..." "Saving to ~/Videos/Recording_$TIMESTAMP.mp4"
    wf-recorder -f "$HOME/Videos/Recording_$TIMESTAMP.mp4" &
    ;;

  "Stop Recording")
    pkill wf-recorder && notify-send "Recording stopped"
    ;;

  *)
    ;;
esac
