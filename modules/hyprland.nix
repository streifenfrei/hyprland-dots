{ config, pkgs, lib, ... }:

let
  nixGL = import ../gpu.config.nix { inherit pkgs; };
in
{
  xdg.enable = true;

  xdg.configFile."foot".source = ../home/foot;
  xdg.configFile."hypr".source = ../home/hypr;
  xdg.configFile."swaync".source = ../home/swaync;
  xdg.configFile."swayosd".source = ../home/swayosd;

  xdg.configFile."walker/config.toml".source = ../home/walker/config.toml;
  xdg.configFile."walker/themes/custom.toml".source = ../home/walker/themes/custom.toml;
  xdg.configFile."walker/themes/custom.css".source = ../home/walker/themes/custom.css;

  home.activation.initWalkerTheme =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -L "$HOME/.config/walker" ]; then
        rm "$HOME/.config/walker"
      fi
      mkdir -p "$HOME/.config/walker/themes"
    '';

  xdg.configFile."waybar".source = ../home/waybar;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = "$HOME";
    music = "$HOME";
    templates = "$HOME";
    publicShare = "$HOME";

    download = "${config.home.homeDirectory}/downloads";
    documents = "${config.home.homeDirectory}/documents";
    pictures = "${config.home.homeDirectory}/pictures";
    videos = "${config.home.homeDirectory}/videos";
  };

  home.packages = with pkgs; [
        nixGL.package

        hypridle
        hyprlock
        hyprpolkitagent
        #xdg-desktop-portal-hyprland TODO:fix
        (pkgs.writeShellScriptBin "hyprpaper-wrapped" ''${nixGL.bin} ${hyprpaper}/bin/hyprpaper "$@"'')
        brightnessctl
        networkmanagerapplet
  ];
}