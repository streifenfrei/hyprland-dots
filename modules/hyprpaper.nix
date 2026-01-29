{ config, pkgs, ... }:

let
  nixGL = import ../gpu.config.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    hyprpaper
    nixGL.package
    ];

  systemd.user.services.hyprpaper = {
    Unit = {
      Description = "Hyprpaper";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${nixGL.bin} ${pkgs.hyprpaper}/bin/hyprpaper";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}