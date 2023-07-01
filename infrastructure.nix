let
  # nixos-22.05 as of 2022-10-09, fetched by niv for commodity
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { allowAliases = false; warnUndeclaredOptions = true; };

  secret-for-root = filename: hostname: {
    "${filename}" = {
      source = "./secrets/${hostname}/${filename}";
      destination = "/var/secrets/${filename}";
      owner = {
        user = "root";
        group = "root";
      };
      permissions = "0400";
    };
  };

  wg-private-key = secret-for-root "wg-private-key";
  nix-serve-private-key = secret-for-root "nix-serve-private-key";
in

{ domain
, aliases
, acme-email
, safe-ips
, ssh-keys
, wg-peers
, resolver
, matomo-hostname
, freelancing ? null
, ...
}:

{
  network = {
    inherit pkgs;
    description = "Personal infrastructure";
  };

  dev-01 = { ... }: {
    deployment.tags = [ "workstation" ];
    deployment.secrets =
      wg-private-key "dev-01" //
      # Following key has been generated with:
      # `nix-store --generate-binary-cache-key dev-01-1 nix-serve-private-key nix-serve-public-key`
      nix-serve-private-key "dev-01";

    imports = [
      ./dev-01.nix
    ];

    personal-infrastructure = {
      root-ssh-keys = [ ssh-keys.local ];
    };
  };

  homepage-02 = { ... }: {
    deployment.tags = [ "web" ];
    deployment.secrets = wg-private-key "homepage-02";

    imports = [
      ./homepage-02.nix
    ];

    services.personal-website = {
      inherit domain aliases;
    };

    services.freelancing =
      if isNull freelancing
      then { enable = false; }
      else {
        enable = true;
        inherit (freelancing) domain root extraConfig aliases;
      };

    personal-infrastructure = {
      inherit acme-email;

      fail2ban = {
        inherit safe-ips;
      };

      matomo = {
        hostname = matomo-hostname;
      };

      root-ssh-keys = [ ssh-keys.remote ];

      tissue = {
        listenIp = resolver.homepage-02;
        other-peers = wg-peers;
      };
    };
  };

  homepage-03 = { ... }: {
    deployment.tags = [ "infra" ];
    deployment.secrets =
      wg-private-key "homepage-03" //
      # Following key has been generated with:
      # `nix-store --generate-binary-cache-key homepage-03-1 nix-serve-private-key nix-serve-public-key`
      nix-serve-private-key "homepage-03";

    imports = [
      ./homepage-03.nix
    ];

    personal-infrastructure = {
      inherit acme-email;

      fail2ban = {
        inherit safe-ips;
      };

      root-ssh-keys = [ ssh-keys.remote ];
    };
  };
}
