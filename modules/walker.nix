{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ walker ];

  systemd.user.services.walker = {
    Unit = {
      Description = "Walker application launcher";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}