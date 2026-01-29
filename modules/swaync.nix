{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ swaynotificationcenter ];

  systemd.user.services.swaynotificationcenter = {
    Unit = {
      Description = "Sway notification center";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}