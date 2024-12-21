{ config, lib, pkgs, ... }:

with lib;

let cfg = config.personal-infrastructure.matomo;
in
{
  options.personal-infrastructure.matomo = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    hostname = mkOption {
      type = types.str;
      example = "matomo.example.org";
    };
  };

  config = mkIf cfg.enable {
    services.matomo = {
      enable = true;
      package = pkgs.matomo;
      nginx = {};
      inherit (cfg) hostname;
    };

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      ensureUsers = [
        {
          name = "kiwi";
          ensurePermissions = {
            "database.matomo" = "ALL PRIVILEGES";
          };
        }
        {
          name = "backup";
          ensurePermissions = {
            "*.*" = "SELECT, LOCK TABLES";
          };
        }
      ];

      ensureDatabases = [ "matomo" ];
    };
  };
}
