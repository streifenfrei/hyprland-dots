{
  description = "Hyprland dotfiles and packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosModules.hyprland-packages = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        # Hyprland core
        hyprland
        hyprpaper
        hyprlock
        hypridle
        
        # Hyprland-related tools
        nautilus
        walker
        waybar
        foot
        swaynotificationcenter
        
        # Add any other Hyprland-related packages here
      ];
    };
  };
}