{ config, lib, pkgs, ... }:

let script = pkgs.callPackage ./package.nix {};
    cfg = config.ptitfred.automation.flake-updater;

    repositoryDefinition = lib.types.submodule {
      options = {
        gitRemoteUrl = lib.mkOption {
          type = lib.types.str;
        };

        githubTokenFile = lib.mkOption {
          type = lib.types.str;
        };

        localWorkingCopy = lib.mkOption {
          type = lib.types.str;
        };

        interval = lib.mkOption {
          default = "24h";
          type = lib.types.str;
          example = "12h";
          description = ''
            The duration between two executions. Should be formatted as a duration understood by systemd.
          '';
        };
      };
    };

    description = "Updates flake inputs for a given repository";

    mkName = name: "flake-updater-${name}";

    toEnvironment = lib.attrsets.mapAttrsToList (name: value: "${name}=${value}");

    mkService = name: options: {
      name = mkName name;
      value = {
        Unit = {
          Description = description;
          After  = [ "default-pre.target" ];
          PartOf = [ "default.target" ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${script}/bin/flake-updater";
          Environment = toEnvironment {
            inherit (options) githubTokenFile gitRemoteUrl localWorkingCopy;
          };
        };

        Install.WantedBy = [ "detault.target" ];
      };
    };

    mkTimer = name: options: {
      name = mkName name;
      value = {
        Unit.Description = description;
        Timer.OnUnitActiveSec = options.interval;
        Install.WantedBy = [ "timers.target" ];
      };
    };

    services = lib.attrsets.mapAttrs' mkService cfg.repositories;
    timers   = lib.attrsets.mapAttrs' mkTimer   cfg.repositories;
 in
{
  options.ptitfred.automation.flake-updater = {
    enable = lib.mkEnableOption "flake-updater" // { inherit description; };

    repositories = lib.mkOption {
      type = lib.types.attrsOf repositoryDefinition;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user = { inherit services timers; };
  };
}
