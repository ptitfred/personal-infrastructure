{ infrastructure, ... }:
{
  deployment.tags = [ "workstation" ];

  imports = [
    ./configuration/home-manager.nix
    hosts/dev-02/configuration.nix
    configuration/personal-infrastructure
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
}
