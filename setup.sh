#!/bin/bash

# Create .desktop files for network and bluetooth menus

# Create directory if it doesn't exist
sudo mkdir -p /usr/share/applications

# Network Menu .desktop file
cat << EOF | sudo tee /usr/share/applications/network-menu.desktop
[Desktop Entry]
Name=Network
Comment=Network control menu
Exec=/home/$USER/.config/tofi/menus/network_menu
Terminal=false
Type=Application
Icon=network-wireless
Categories=Network;System;
EOF

# Bluetooth Menu .desktop file
cat << EOF | sudo tee /usr/share/applications/bluetooth-menu.desktop
[Desktop Entry]
Name=Bluetooth
Comment=Bluetooth control menu
Exec=/home/$USER/.config/tofi/menus/bluetooth_menu
Terminal=false
Type=Application
Icon=bluetooth
Categories=Network;System;
EOF

# Make the .desktop files executable
sudo chmod +x /usr/share/applications/network-menu.desktop
sudo chmod +x /usr/share/applications/bluetooth-menu.desktop

echo "Desktop files created successfully!"
