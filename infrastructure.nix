let
  # nixos-22.05 as of 2022-10-09, fetched by niv for commodity
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};

  wg-private-key = hostname: {
    "wg-private-key" = {
      source = "./secrets/${hostname}/wg-private-key";
      destination = "/var/secrets/wg-private-key";
      owner = {
        user = "root";
        group = "root";
      };
      permissions = "0400";
    };
  };
in

{ domain
, aliases
, acme-email
, safe-ips
, ssh-keys
, wg-peers
, resolver
, ...
}:

{
  network = {
    inherit pkgs;
    description = "Personal infrastructure";
  };

  dev-01 = { ... }: {
    deployment.tags = [ "workstation" ];
    deployment.secrets = wg-private-key "dev-01";

    imports = [
      hosts/dev-01/configuration.nix
      configuration/security.nix
      configuration/wireguard.nix
    ];

    security.personal-infrastructure = {
      root-ssh-keys = [ ssh-keys.local ];

      tissue = {
        publicKey = "XVJY3lSCjQxHBrrEIDTickR01ox/VKtyiWO6I0nkACQ=";
        ip = "10.100.0.3";
        host = "homepage-02";
        joinable = true;
      };
    };

    programs.ssh.startAgent = true;
  };

  homepage-02 = { ... }: {
    deployment.tags = [ "web" ];
    deployment.secrets = wg-private-key "homepage-02";

    imports = [
      hosts/homepage-02.nix
      morph-utils/monitor-nginx.nix
      services/monitoring.nix
      services/website.nix
      configuration/security.nix
      configuration/wireguard.nix
    ];

    services.personal-website = {
      enable = true;
      inherit domain aliases;
    };

    security.acme.defaults.email = acme-email;

    security.personal-infrastructure = {
      inherit safe-ips;
      root-ssh-keys = [ ssh-keys.remote ];

      tissue = {
        publicKey = "WHQ/KKdGP/iuE7ii1lLVq45VKiV4nOdHFSioa1U/XXA=";
        ip = "10.100.0.1";
        listenIp = resolver.homepage-02;
        clients = [ "dev-01" "homepage-03" ];
        other-peers = wg-peers;
      };
    };
  };

  homepage-03 = { ... }: {
    deployment.tags = [ "infra" ];
    deployment.secrets = wg-private-key "homepage-03";

    imports = [
      hosts/homepage-03.nix
      configuration/security.nix
      configuration/wireguard.nix
      services/monitoring.nix
    ];

    security.personal-infrastructure = {
      inherit safe-ips;
      root-ssh-keys = [ ssh-keys.remote ];

      tissue = {
        publicKey = "jOab1ZoQrdbcNSN3qKTOOZ783CdtkCYSnMDXqqIWwXg=";
        ip = "10.100.0.2";
        host = "homepage-02";
        joinable = true;
      };
    };
  };
}
