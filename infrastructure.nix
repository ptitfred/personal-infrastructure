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
      hosts/dev-01/configuration.nix
      configuration/personal-infrastructure
    ];

    personal-infrastructure = {
      root-ssh-keys = [ ssh-keys.local ];

      nix-cache.enable = true;

      tissue = {
        publicKey = "XVJY3lSCjQxHBrrEIDTickR01ox/VKtyiWO6I0nkACQ=";
        ip = "10.100.0.3";
        host = "homepage-02";
        reachable = true;
        open-ports = [ 3000 ];
      };
    };
  };

  homepage-02 = { ... }: {
    deployment.tags = [ "web" ];
    deployment.secrets = wg-private-key "homepage-02";

    imports = [
      hosts/homepage-02.nix
      configuration/personal-infrastructure
      morph-utils/monitor-nginx.nix
      services/website.nix
      services/freelancing.nix
    ];

    services.personal-website = {
      enable = true;
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
        enable = true;
        inherit safe-ips;
      };

      matomo = {
        enable = true;
        hostname = matomo-hostname;
      };

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
    deployment.secrets =
      wg-private-key "homepage-03" //
      # Following key has been generated with:
      # `nix-store --generate-binary-cache-key homepage-03-1 nix-serve-private-key nix-serve-public-key`
      nix-serve-private-key "homepage-03";

    imports = [
      hosts/homepage-03.nix
      configuration/personal-infrastructure
    ];

    personal-infrastructure = {
      inherit acme-email;

      fail2ban = {
        enable = true;
        inherit safe-ips;
      };

      root-ssh-keys = [ ssh-keys.remote ];

      nix-cache = {
        enable = true;
        domain = "cache.menou.me";
      };

      tissue = {
        publicKey = "jOab1ZoQrdbcNSN3qKTOOZ783CdtkCYSnMDXqqIWwXg=";
        ip = "10.100.0.2";
        host = "homepage-02";
        reachable = true;
      };
    };
  };
}
