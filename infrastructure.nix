let
  # nixos-22.05 as of 2022-10-09, fetched by niv for commodity
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in

{ domain, aliases, acme-email, safe-ips, ssh-keys, ... }:

{
  network = {
    inherit pkgs;
    description = "Personal infrastructure";
  };

  dev-01 = { ... }: {
    deployment = {
      tags = [ "workstation" ];
    };

    imports = [
      hosts/dev-01/configuration.nix
      configuration/security.nix
    ];

    security.personal-infrastructure.root-ssh-keys = [ ssh-keys.local ];
  };

  homepage-02 = { ... }: {
    deployment.tags = [ "web" ];

    imports = [
      hosts/homepage-02.nix
      morph-utils/monitor-nginx.nix
      services/website.nix
      configuration/security.nix
    ];

    services.personal-website = {
      enable = true;
      inherit domain aliases;
    };

    security.acme.defaults.email = acme-email;

    security.personal-infrastructure = {
      inherit safe-ips;
      root-ssh-keys = [ ssh-keys.remote ];
    };
  };

  homepage-03 = { ... }: {
    deployment.tags = [ "infra" ];

    imports = [
      hosts/homepage-03.nix
      configuration/security.nix
    ];

    security.personal-infrastructure = {
      inherit safe-ips;
      root-ssh-keys = [ ssh-keys.remote ];
    };
  };
}
