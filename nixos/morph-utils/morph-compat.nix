{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let healthCheckType = submodule ({ ... }: {
      options = {
        cmd = mkOption {
          type = listOf cmdHealthCheckType;
          default = [];
          description = "List of command health checks";
        };
        http = mkOption {
          type = listOf httpHealthCheckType;
          default = [];
          description = "List of HTTP health checks";
        };
      };
    });

    httpHealthCheckType = types.submodule ({ ... }: {
      options = {
        description = mkOption {
            type = str;
            description = "Health check description";
        };
        host = mkOption {
          type = nullOr str;
          description = "Host name";
          default = null;
          #default = config.networking.hostName;
        };
        scheme = mkOption {
          type = str;
          description = "Scheme";
          default = "http";
        };
        port = mkOption {
          type = int;
          description = "Port number";
        };
        path = mkOption {
          type = path;
          description = "HTTP request path";
          default = "/";
        };
        headers = mkOption {
          type = attrsOf str;
          description = "HTTP request headers";
          default = {};
        };
        period = mkOption {
          type = int;
          description = "Seconds between checks";
          default = 2;
        };
        timeout = mkOption {
          type = int;
          description = "Timeout in seconds";
          default = 5;
        };
        insecureSSL = mkOption {
          type = bool;
          description = "Ignore SSL errors";
          default = false;
        };
      };
    });

    cmdHealthCheckType = types.submodule ({ ... }: {
      options = {
        description = mkOption {
            type = str;
            description = "Health check description";
        };
        cmd = mkOption {
            type = nullOr (listOf str);
            description = "Command to run as list";
            default = null;
        };
        period = mkOption {
          type = int;
          description = "Seconds between checks";
          default = 2;
        };
        timeout = mkOption {
          type = int;
          description = "Timeout in seconds";
          default = 5;
        };
      };
    });

in {
  options.deployment = {
    healthChecks = mkOption {
      type = healthCheckType;
      description = ''
        Health check configuration.
      '';
      default = {};
    };
  };

  # Creates a txt-file that lists all system healthcheck commands
  # The file will end up linked in /run/current-system along with
  # all derived dependencies.
  config.system.extraDependencies =
  let
    cmds = concatMap (h: h.cmd) config.deployment.healthChecks.cmd;
  in
  [ (pkgs.writeText "healthcheck-commands.txt" (concatStringsSep "\n" cmds)) ];
}
