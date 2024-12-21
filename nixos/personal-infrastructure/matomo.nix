{ config, lib, pkgs, ... }:

with lib;

let cfg = config.personal-infrastructure.matomo;

    version = "5.2.1";
    hash = "sha256-5glMwwIG0Uo8bu904u40FUa+yaUlrQe1nUCkv9/ATks=";

    # matomo_5 in nixpkgs is at 5.1.1 as of this commit
    package = pkgs.matomo_5.overrideAttrs {
      name = "matomo_5-${version}";
      inherit version;
      src = pkgs.fetchurl {
        url = "https://builds.matomo.org/matomo-${version}.tar.gz";
        inherit hash;
      };
    };
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
      inherit package;
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
