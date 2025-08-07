let 
  swayosd_patched = pkgs.swayosd.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./patches/swayosd.patch ];
  });
in
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
        foot
        nautilus
        networkmanagerapplet
        swaynotificationcenter
        swayosd_patched
        walker
        waybar
      ];
    };
  };
}