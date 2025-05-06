#!/bin/bash

# Configuration
PROXY_HOST="127.0.0.1"
PROXY_PORT="7890"
PROXY_URL="http://${PROXY_HOST}:${PROXY_PORT}"
RCFILE="$HOME/.bashrc"
PROXY_MARKER_START="# START_PROXY_SETTINGS"
PROXY_MARKER_END="# END_PROXY_SETTINGS"

# Function to check if proxy is enabled
is_proxy_enabled() {
    if grep -q "$PROXY_MARKER_START" "$RCFILE"; then
        return 0
    else
        return 1
    fi
}

# Function to enable proxy
enable_proxy() {
    # Remove any existing proxy settings
    sed "/$PROXY_MARKER_START/,/$PROXY_MARKER_END/d" "$RCFILE" > "$RCFILE.tmp" && mv "$RCFILE.tmp" "$RCFILE"
    
    # Add new proxy settings
    cat << EOF >> "$RCFILE"

$PROXY_MARKER_START
export http_proxy="$PROXY_URL"
export HTTP_PROXY="$PROXY_URL"
export https_proxy="$PROXY_URL"
export HTTPS_PROXY="$PROXY_URL"
export all_proxy="$PROXY_URL"
export ALL_PROXY="$PROXY_URL"
$PROXY_MARKER_END
EOF

    # Set system-wide proxy settings
    gsettings set org.gnome.system.proxy mode 'manual'
    gsettings set org.gnome.system.proxy.http host "$PROXY_HOST"
    gsettings set org.gnome.system.proxy.http port "$PROXY_PORT"
    gsettings set org.gnome.system.proxy.https host "$PROXY_HOST"
    gsettings set org.gnome.system.proxy.https port "$PROXY_PORT"

    # Notify user
    notify-send "Proxy Enabled" "System proxy has been enabled"
}

# Function to disable proxy
disable_proxy() {
    # Remove proxy settings exports
    sed "/$PROXY_MARKER_START/,/$PROXY_MARKER_END/d" "$RCFILE" > "$RCFILE.tmp" && mv "$RCFILE.tmp" "$RCFILE"

    # Disable system-wide proxy settings
    gsettings set org.gnome.system.proxy mode 'none'

    # Notify user
    notify-send "Proxy Disabled" "System proxy has been disabled"
}

# Main toggle logic
if is_proxy_enabled; then
    disable_proxy
else
    enable_proxy
fi
