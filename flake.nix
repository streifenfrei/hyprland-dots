{
  description = "Hyprland dotfiles and packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    swayosd_patched = nixpkgs.legacyPackages.x86_64-linux.swayosd.overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ./patches/swayosd.patch ];
    });
  in {
    nixosModules.hyprland-packages = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        # Hyprland core
        hypridle
        hyprlock
        hyprpaper
        hyprshot
        
        # Hyprland-related tools
        foot
        nautilus
        networkmanagerapplet
        swaynotificationcenter
        swayosd_patched
        electron-mail
        walker
        waybar
      ];
    };
  };
}