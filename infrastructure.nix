{ pkgs, inputs, ... }:

{
  meta = {
    description = "Personal infrastructure";
    nixpkgs = pkgs;
    specialArgs = {
      inherit inputs;
    };
  };

  dev-01 = { infrastructure, ... }: {
    deployment.tags = [ "workstation" ];

    imports = [
      ./configuration/home-manager.nix
      ./dev-01.nix
    ];

    personal-infrastructure = {
      root-ssh-keys = [ infrastructure.ssh-keys.local ];
    };
  };

  homepage-02 = { inputs, infrastructure, ... }: {
    deployment.tags = [ "web" ];

    imports = [
      ./homepage-02.nix
    ];

    services.personal-website = {
      inherit (infrastructure) domain aliases;
    };

    services.freelancing =
      if isNull infrastructure.freelancing
      then { enable = false; }
      else {
        enable = true;
        inherit (infrastructure.freelancing inputs) domain root extraConfig aliases;
      };

    personal-infrastructure = {
      inherit (infrastructure) acme-email;

      fail2ban = {
        inherit (infrastructure) safe-ips;
      };

      matomo = {
        hostname = infrastructure.matomo-hostname;
      };

      root-ssh-keys = [ infrastructure.ssh-keys.remote ];

      tissue = {
        listenIp = infrastructure.resolver.homepage-02;
        other-peers = infrastructure.wg-peers;
      };
    };
  };

  homepage-03 = { infrastructure, ... }: {
    deployment.tags = [ "infra" ];

    imports = [
      ./homepage-03.nix
    ];

    personal-infrastructure = {
      inherit (infrastructure) acme-email;

      fail2ban = {
        inherit (infrastructure) safe-ips;
      };

      root-ssh-keys = [ infrastructure.ssh-keys.remote ];
    };
  };
}
