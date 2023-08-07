{ infrastructure, ... }:
{
  deployment.tags = [ "workstation" ];

  imports = [
    ./configuration.nix
    ../../nixos/backlight.nix
    ../../nixos/home-manager.nix
    ../../nixos/personal-infrastructure
    ../../nixos/workstation.nix
  ];

  personal-infrastructure = {
    nix-cache.enable = true;

    tissue = {
      publicKey = "NLCWc9YGiimqRJAZpvK6AK8NwiKd5JE5B564adtkLSk=";
      ip = "10.100.0.10";
      host = "homepage-02";
      reachable = true;
      open-ports = [ 3000 ];
    };

    root-ssh-keys = [ infrastructure.ssh-keys.local ];
  };

  backlight-support = {
    enable = true;
    user = "frederic";
  };
}
