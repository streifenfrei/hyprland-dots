{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ waybar ];

  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}