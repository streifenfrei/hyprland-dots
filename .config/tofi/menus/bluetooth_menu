#!/bin/bash

# Bluetooth control script for Hyprland using bluetoothctl and Tofi

# Function to filter out devices with only MAC addresses in the name
get_named_devices() {
    local filter="$1"
    if [ -n "$filter" ]; then
        bluetoothctl devices "$filter" | awk '{if ($3 !~ /^[0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f]$/) print $0}'
    else
        bluetoothctl devices | awk '{if ($3 !~ /^[0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f][:-][0-9A-Fa-f][0-9A-Fa-f]$/) print $0}'
    fi
}

# Function to extract device name from a line
get_device_name() {
    local devices="$1"
    while IFS= read -r line; do
        echo "$line" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}'
    done <<< "$devices"
}

# Function to extract MAC address from a line matching a name
get_mac_from_name() {
    local devices="$1"
    local name="$2"
    while IFS= read -r line; do
        local full_name=$(echo "$line" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ $//')
        if [ "$full_name" = "$name" ]; then
            echo "$line" | awk '{print $2}'
            return
        fi
    done <<< "$devices"
}

while true; do
    # Get current power state
    if bluetoothctl show | grep -q "Powered: yes"; then
        POWER_STATE="ON"
    else
        POWER_STATE="OFF"
    fi

    # Get current pairable state
    if bluetoothctl show | grep -q "Pairable: yes"; then
        PAIRABLE_STATE="ON"
    else
        PAIRABLE_STATE="OFF"
    fi

    # Get current discoverable state
    if bluetoothctl show | grep -q "Discoverable: yes"; then
        DISCOVERABLE_STATE="ON"
    else
        DISCOVERABLE_STATE="OFF"
    fi

    # Check if any devices are connected
    CONNECTED_DEVICES=$(bluetoothctl devices Connected | wc -l)
    if [ "$CONNECTED_DEVICES" -gt 0 ]; then
        HAS_CONNECTED_DEVICES=true
    else
        HAS_CONNECTED_DEVICES=false
    fi

    # Show different options based on power state
    if [ "$POWER_STATE" = "ON" ]; then
        if [ "$HAS_CONNECTED_DEVICES" = true ]; then
            CHOICE=$(printf "Power: $POWER_STATE\nPairable: $PAIRABLE_STATE\nDiscoverable: $DISCOVERABLE_STATE\nDevices\nDisconnect" | tofi --prompt "Bluetooth Control : ")
        else
            CHOICE=$(printf "Power: $POWER_STATE\nPairable: $PAIRABLE_STATE\nDiscoverable: $DISCOVERABLE_STATE\nDevices" | tofi --prompt "Bluetooth Control : ")
        fi
    else
        CHOICE=$(printf "Power: $POWER_STATE" | tofi --prompt "Bluetooth Control : ")
    fi

    # If no choice was made (ESC pressed), exit the script
    if [ -z "$CHOICE" ]; then
        break
    fi

    case "$CHOICE" in
      "Power: ON"|"Power: OFF")
        if [ "$POWER_STATE" = "ON" ]; then
          bluetoothctl power off
          notify-send "Bluetooth" "Power turned off"
        else
          bluetoothctl power on
          notify-send "Bluetooth" "Power turned on"
        fi
        ;;

      "Pairable: ON"|"Pairable: OFF")
        if [ "$PAIRABLE_STATE" = "ON" ]; then
          bluetoothctl pairable off
          notify-send "Bluetooth" "Pairable mode turned off"
        else
          bluetoothctl pairable on
          notify-send "Bluetooth" "Pairable mode turned on"
        fi
        ;;

      "Discoverable: ON"|"Discoverable: OFF")
        if [ "$DISCOVERABLE_STATE" = "ON" ]; then
          bluetoothctl discoverable off
          notify-send "Bluetooth" "Discoverable mode turned off"
        else
          bluetoothctl discoverable on
          notify-send "Bluetooth" "Discoverable mode turned on"
        fi
        ;;

      "Devices")
        # Start scanning if not already scanning
        if ! bluetoothctl show | grep -q "Discovering: yes"; then
            bluetoothctl --timeout 10 scan on &
        fi

        while true; do
            DEVICES=$(get_named_devices)
            if [ -n "$DEVICES" ]; then
                SELECTED_NAME=$(printf "Back\nRefresh\n$(get_device_name "$DEVICES")" | tofi --prompt "Select device : ")
                # If no choice was made (ESC pressed), exit the script
                if [ -z "$SELECTED_NAME" ]; then
                    break 2
                fi
                if [ "$SELECTED_NAME" = "Back" ]; then
                    continue 2
                fi
                if [ "$SELECTED_NAME" = "Refresh" ]; then
                    bluetoothctl --timeout 10 scan on &
                    continue
                fi
                MAC=$(get_mac_from_name "$DEVICES" "$SELECTED_NAME")
                while true; do
                    DEVICE_ACTION=$(printf "Back\nConnect\nInfo" | tofi --prompt "Select action for $SELECTED_NAME : ")
                    # If no choice was made (ESC pressed), exit the script
                    if [ -z "$DEVICE_ACTION" ]; then
                        break 3
                    fi
                    case "$DEVICE_ACTION" in
                        "Back")
                            continue 2
                            ;;
                        "Connect")
                            bluetoothctl connect "$MAC"
                            notify-send "Bluetooth" "Connecting to $SELECTED_NAME"
                            continue 2
                            ;;
                        "Info")
                            INFO=$(bluetoothctl info "$MAC")
                            notify-send "Bluetooth Device Info" "$INFO"
                            ;;
                    esac
                done
            else
                SELECTED_NAME=$(printf "Back\nRefresh" | tofi --prompt "No devices found : ")
                if [ -z "$SELECTED_NAME" ]; then
                    break 2
                fi
                if [ "$SELECTED_NAME" = "Back" ]; then
                    continue 2
                fi
                if [ "$SELECTED_NAME" = "Refresh" ]; then
                    bluetoothctl --timeout 10 scan on &
                    continue
                fi
            fi
        done
        ;;

      "Disconnect")
        while true; do
            CONNECTED_DEVICES=$(get_named_devices "Connected")
            if [ -n "$CONNECTED_DEVICES" ]; then
                SELECTED_NAME=$(printf "Back\n$(get_device_name "$CONNECTED_DEVICES")" | tofi --prompt "Select device to disconnect : ")
                # If no choice was made (ESC pressed), exit the script
                if [ -z "$SELECTED_NAME" ]; then
                    break 2
                fi
                if [ "$SELECTED_NAME" = "Back" ]; then
                    continue 2
                fi
                MAC=$(get_mac_from_name "$CONNECTED_DEVICES" "$SELECTED_NAME")
                bluetoothctl disconnect "$MAC"
                notify-send "Bluetooth" "Disconnecting from $SELECTED_NAME"
                continue
            else
                notify-send "Bluetooth" "No connected devices"
                continue 2
            fi
        done
        ;;

      *)
        continue
        ;;
    esac
done
