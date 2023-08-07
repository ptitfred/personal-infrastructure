{ infrastructure, ... }:
{
  deployment.tags = [ "infra" ];

  imports = [
    ../../nixos/hardware/ovhcloud
    ../../nixos/personal-infrastructure
  ];

  networking.hostName = "homepage-03";

  system.stateVersion = "22.05";

  personal-infrastructure = {
    inherit (infrastructure) acme-email;

    fail2ban = {
      enable = true;
      inherit (infrastructure) safe-ips;
    };

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

    root-ssh-keys = [ infrastructure.ssh-keys.remote ];
  };
}
