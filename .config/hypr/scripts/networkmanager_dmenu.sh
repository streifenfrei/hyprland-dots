#!/usr/bin/env bash

# Ensure we have the correct environment variables
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# Check if we're running under uwsm
if [ -n "$UWSM_SESSION" ]; then
    # Run in a subshell to prevent session termination
    (
        # Ensure we're not in the session manager's process group
        setsid ~/.config/networkmanager_dmenu
    ) &
else
    # Normal execution if not under uwsm
    ~/.config/networkmanager_dmenu
fi 