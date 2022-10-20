let
  # nixos-22.05 as of 2022-10-09, fetched by niv for commodity
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in

{ domain, aliases, acme-email, safe-ips, ssh-key }:

{
  network = {
    inherit pkgs;
    description = "Personal infrastructure";
  };

  homepage-02 = { ... }: {
    deployment.tags = [ "web" ];

    imports = [
      hosts/homepage-02.nix
      morph-utils/monitor-nginx.nix
      services/website.nix
    ];

    services.personal-website = {
      enable = true;
      inherit domain aliases;
    };

    security.acme.defaults.email = acme-email;

    security.personal-infrastructure = {
      inherit safe-ips;
    };
  };

  homepage-03 = { ... }: {
    deployment.tags = [ "infra" ];

    imports = [
      hosts/homepage-03.nix
    ];

    cloud-providers.ovh.root-ssh-key = ssh-key;

    security.personal-infrastructure = {
      inherit safe-ips;
    };
  };
}
