{
  description = "Hyprland dotfiles and packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosModules.hyprland-packages = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        # Hyprland core
        hyprpaper
        hyprlock
        hypridle
        
        # Hyprland-related tools
        avizo
        foot
        nautilus
        networkmanagerapplet
        swaynotificationcenter
        walker
        waybar
      ];
    };
  };
}