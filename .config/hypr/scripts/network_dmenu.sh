#!/bin/bash

# Network control script for Hyprland using nmcli and Tofi

# Function to get wifi status
get_wifi_status() {
    if nmcli radio wifi | grep -q "enabled"; then
        echo "ON"
    else
        echo "OFF"
    fi
}

# Function to get wwan status
get_wwan_status() {
    if nmcli radio wwan | grep -q "enabled"; then
        echo "ON"
    else
        echo "OFF"
    fi
}

# Function to get wifi networks
get_wifi_networks() {
    nmcli -t -f SSID,SIGNAL,SECURITY device wifi list
}

# Function to get connected wifi network
get_connected_wifi() {
    nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep wifi | cut -d: -f1
}

# Function to get ethernet connections
get_ethernet_connections() {
    nmcli -t -f NAME,TYPE,DEVICE connection show | grep ethernet | while IFS=: read -r name type device; do
        # Check if connection is active
        if nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep -q "^$name:$type:$device$"; then
            echo "$name ✓"
        else
            echo "$name"
        fi
    done
}

# Function to format wifi network display
format_wifi_networks() {
    local networks="$1"
    while IFS=: read -r ssid signal security; do
        # Remove quotes from SSID and check if it's empty
        ssid=$(echo "$ssid" | sed 's/^"//;s/"$//')
        if [ -z "$ssid" ]; then
            continue
        fi
        # Format signal strength
        signal="${signal}%"
        # Format security
        if [ -n "$security" ]; then
            security="🔒"
        else
            security=""
        fi
        # Output in format that can be sorted by signal strength
        printf "%s\t%s\t%s\n" "$signal" "$ssid" "$security"
    done <<< "$networks" | sort -nr | awk -F'\t' '{print $2 " " $1 " " $3}'
}

# Create a temporary file for storing choices
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

while true; do
    # Get current wifi state
    WIFI_STATE=$(get_wifi_status)
    
    # Get current wwan state
    WWAN_STATE=$(get_wwan_status)

    # Show main menu options
    echo -e "Ethernet\nWiFi\nWWAN: $WWAN_STATE\nEdit Connections" > "$TMP_FILE"
    CHOICE=$(tofi --prompt "Network Control : " < "$TMP_FILE")

    # If no choice was made (ESC pressed), exit the script
    if [ -z "$CHOICE" ]; then
        break
    fi

    case "$CHOICE" in
        "Ethernet")
            while true; do
                # Get ethernet connections
                CONNECTIONS=$(get_ethernet_connections)
                
                # Show ethernet menu
                echo -e "Back\n$CONNECTIONS" > "$TMP_FILE"
                ETHERNET_CHOICE=$(tofi --prompt "Ethernet Connections : " < "$TMP_FILE")
                
                # If no choice was made (ESC pressed), go back to main menu
                if [ -z "$ETHERNET_CHOICE" ]; then
                    break
                fi
                
                case "$ETHERNET_CHOICE" in
                    "Back")
                        break
                        ;;
                    *)
                        # Remove checkmark if present
                        CONNECTION_NAME=$(echo "$ETHERNET_CHOICE" | sed 's/ ✓$//')
                        
                        # Check if connection is active
                        if [[ "$ETHERNET_CHOICE" == *"✓"* ]]; then
                            # Deactivate connection
                            nmcli connection down "$CONNECTION_NAME"
                            notify-send "Network" "Disconnected from $CONNECTION_NAME"
                        else
                            # Activate connection
                            nmcli connection up "$CONNECTION_NAME"
                            notify-send "Network" "Connected to $CONNECTION_NAME"
                        fi
                        ;;
                esac
            done
            ;;

        "WiFi")
            while true; do
                # Get current wifi state
                WIFI_STATE=$(get_wifi_status)
                
                # Get current connected network
                CONNECTED=$(get_connected_wifi)
                
                # Get available networks
                NETWORKS=$(get_wifi_networks)
                
                # Format networks for display
                FORMATTED_NETWORKS=$(format_wifi_networks "$NETWORKS")
                
                # Show WiFi menu
                if [ "$WIFI_STATE" = "ON" ]; then
                    echo -e "Back\nWiFi: $WIFI_STATE\n$FORMATTED_NETWORKS" > "$TMP_FILE"
                else
                    echo -e "Back\nWiFi: $WIFI_STATE" > "$TMP_FILE"
                fi
                WIFI_CHOICE=$(tofi --prompt "WiFi Networks : " < "$TMP_FILE")
                
                # If no choice was made (ESC pressed), go back to main menu
                if [ -z "$WIFI_CHOICE" ]; then
                    break
                fi
                
                case "$WIFI_CHOICE" in
                    "Back")
                        break
                        ;;
                        
                    "WiFi: ON"|"WiFi: OFF")
                        if [ "$WIFI_STATE" = "ON" ]; then
                            nmcli radio wifi off
                            notify-send "Network" "WiFi turned off"
                        else
                            nmcli radio wifi on
                            notify-send "Network" "WiFi turned on"
                            # Wait for WiFi to initialize and force a scan
                            sleep 4
                            nmcli device wifi rescan
                        fi
                        ;;
                        
                    *)
                        # Extract SSID from the selected network (everything before the first space followed by a number and %)
                        SSID=$(echo "$WIFI_CHOICE" | sed 's/ [0-9]*%.*$//')
                        
                        # Check if network is already connected
                        if [ "$SSID" = "$CONNECTED" ]; then
                            # Disconnect from current network
                            nmcli connection down "$SSID"
                            notify-send "Network" "Disconnected from $SSID"
                        else
                            # Check if network is secured (has 🔒)
                            if [[ "$WIFI_CHOICE" == *"🔒"* ]]; then
                                # Get password using pinentry
                                PASSWORD=$(echo "SETTITLE WiFi Password
SETDESC Enter password for $SSID
GETPIN" | pinentry | grep "D " | cut -d' ' -f2-)
                                
                                if [ -n "$PASSWORD" ]; then
                                    # Try to connect to the network with password
                                    nmcli device wifi connect "$SSID" password "$PASSWORD"
                                    notify-send "Network" "Connecting to $SSID"
                                else
                                    notify-send "Network" "Password required but not provided"
                                fi
                            else
                                # Try to connect to the network without password
                                nmcli device wifi connect "$SSID"
                                notify-send "Network" "Connecting to $SSID"
                            fi
                        fi
                        ;;
                esac
            done
            ;;

        "WWAN: ON"|"WWAN: OFF")
            if [ "$WWAN_STATE" = "ON" ]; then
                nmcli radio wwan off
                notify-send "Network" "WWAN turned off"
            else
                nmcli radio wwan on
                notify-send "Network" "WWAN turned on"
            fi
            ;;

        "Edit Connections")
            nm-connection-editor &
            break
            ;;

        *)
            continue
            ;;
    esac
done