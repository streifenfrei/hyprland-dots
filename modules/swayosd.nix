{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ swayosd ];

  systemd.user.services.swayosd = {
    Unit = {
      Description = "OSD for volume and brightness control";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}