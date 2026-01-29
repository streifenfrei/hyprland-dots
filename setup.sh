#!/usr/bin/bash

confirm_command() {
    local cmd="$1"
    # ANSI color codes
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)

    read -p "${YELLOW}${BOLD}Run: '${GREEN}$cmd${YELLOW}'? [Y/n] ${RESET}" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        eval "$cmd"
        return 0
    else
        echo "${RED}${BOLD}Skipped: $cmd${RESET}"
        return 1
    fi
}

confirm_command "sudo pacman -Sy git"
confirm_command "git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay"
confirm_command "sudo pacman -Sy hyprland hyprpaper swaync swayosd walker waybar"
confirm_command "yay -Sy elephant-desktopapplications"
confirm_command "yay -Sy nerd-fonts"

