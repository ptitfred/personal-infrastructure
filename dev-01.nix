{ infrastructure, ... }:
{
  deployment.tags = [ "workstation" ];

  imports = [
    ./configuration/home-manager.nix
    hosts/dev-01/configuration.nix
    configuration/personal-infrastructure
  ];

  personal-infrastructure = {
    nix-cache.enable = true;

    tissue = {
      publicKey = "XVJY3lSCjQxHBrrEIDTickR01ox/VKtyiWO6I0nkACQ=";
      ip = "10.100.0.3";
      host = "homepage-02";
      reachable = true;
      open-ports = [ 3000 ];
    };

    root-ssh-keys = [ infrastructure.ssh-keys.local ];
  };
}
