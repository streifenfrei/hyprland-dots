{ config, pkgs, ... }:

{
  home.username = "dave";
  home.homeDirectory = "/home/dave";

  home.stateVersion = "24.05";

  #home.packages = with pkgs; [];

  programs.home-manager.enable = true;

  imports = [
    ../modules/foot.nix
    ../modules/hyprland.nix
    ../modules/hyprpaper.nix
    ../modules/swaync.nix
    ../modules/swayosd.nix
    ../modules/walker.nix
    ../modules/waybar.nix
  ];
}
