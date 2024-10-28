{ inputs
, httpie
, cores
, memorySize
, pkgs
}:

let secret = filename: hostname: {
      "${filename}" = {
        keyFile = "/tmp/${hostname}-${filename}";
        destDir = "/var/secrets";
      };
    };

    wg-private-key = secret "wg-private-key";
in

pkgs.testers.runNixOSTest({...}: {
  name = "personal-integration-servers";
  nodes.server_01 = { config, ... }: {
    # Configuration of the VM
    virtualisation = { inherit cores memorySize; };
    networking.hostName = "server-01";
    system.stateVersion = "24.05";

    # Dependencies for the testing script
    environment.systemPackages = [ httpie ];

    # Actual machine configuration
    imports = [
      # Some of our code relies on colmena options. As this machine isn't built
      # by colmena, we have to explicitly import it.
      # Fortunately it's as easy as the following:
      inputs.colmena.nixosModules.deploymentOptions

      # Root modules exposed by this repository
      ../nixos/personal-infrastructure
      ../nixos/services/website.nix
    ];

    # Configuration related to the tested modules:

    deployment.keys = wg-private-key config.networking.hostName;

    services.personal-website = {
      enable = true;
      domain = "long.test.localhost";
      aliases = [ "test.localhost" ];
      redirections = [
        { path = "/example";  target = "http://long.test.localhost/open-source"; }
        { path = "/example/"; target = "http://long.test.localhost/open-source"; }
      ];

      # Explicitly disable HTTPs as we can't have the ACME dance in the VM
      secure = false;
    };

    personal-infrastructure = {
      root-ssh-keys = [ (builtins.readFile ./key.pub) ];
      tissue = {
        ip = "10.0.0.1";
      };
    };
  };

  testScript = builtins.readFile ./integration-test.py;
})
