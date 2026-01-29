{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ foot ];

  systemd.user.services.foot = {
    Unit = {
      Description = "Foot server";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.foot}/bin/foot --server";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}