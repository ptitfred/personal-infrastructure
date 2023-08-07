{ config, inputs, lib, ... }:

let
  cfg = config.personal-infrastructure.nix-cache;

  isPrivate = cfg.domain == null;
in

{
  imports = [ inputs.nix-serve-ng.nixosModules.default ];

  options.personal-infrastructure.nix-cache = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "cache.example.org";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nix-serve.enable = true;
    services.nix-serve.secretKeyFile = "${config.deployment.keys.nix-serve-private-key.destDir}/nix-serve-private-key";

    services.nix-serve.bindAddress = if isPrivate then config.personal-infrastructure.tissue.ip else "127.0.0.1";

    networking.firewall.allowedTCPPorts = lib.mkIf (! isPrivate) [ 80 443 ];
    networking.firewall.interfaces."tissue".allowedTCPPorts = lib.mkIf isPrivate [ config.services.nix-serve.port ];

    services.nginx = lib.mkIf (! isPrivate) {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.nix-serve.port}/";
        };
      };
    };
  };
}
