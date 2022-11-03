let
  sources = import ../nix/sources.nix;
  nix-serve-ng = import sources.nix-serve-ng;
in

{ config, ... }:
{
  imports = [ nix-serve-ng.nixosModules.default ];

  services.nix-serve = {
    enable = true;
    bindAddress = config.security.personal-infrastructure.tissue.ip;
    secretKeyFile = config.deployment.secrets.nix-serve-private-key.destination;
  };

  networking.firewall.interfaces."tissue".allowedTCPPorts = [ config.services.nix-serve.port ];
}
