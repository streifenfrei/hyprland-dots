#!/usr/bin/env bash

# Usage: start_or_focus.sh <program> <window_class> [args...]

PROGRAM="$1"
WINCLASS="$2"
shift 2

# Get all windows info from hyprctl
WINDOWS=$(hyprctl clients -j)

# Try to find a window whose class matches the given window class (case-insensitive)
MATCH=$(echo "$WINDOWS" | jq -r --arg class "$WINCLASS" '
  .[] | select(.class | ascii_downcase == ($class | ascii_downcase)) | .workspace.id
' | head -n1)

if [[ -n "$MATCH" ]]; then
  # Window exists, switch to its workspace
  hyprctl dispatch workspace "$MATCH"
else
  # No window found, start the program
  "$PROGRAM" "$@" &
fi
