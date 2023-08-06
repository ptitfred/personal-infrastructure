let infrastructure =
      {
        domain = "test.localhost";
        aliases = [ "localhost" "test2.localhost" ];
        acme-email = "acme@localhost";
        safe-ips = [ "1.1.1.1" ];
        ssh-keys = {
          local  = builtins.readFile ./key.pub;
          remote = builtins.readFile ./key.pub;
        };
        wg-peers = [];
        resolver = { homepage-02 = "127.0.0.1"; };
        matomo-hostname = "matomo.localhost";
      };

    secret = filename: hostname: {
      "${filename}" = {
        keyFile = "/tmp/${hostname}-${filename}";
        destDir = "/var/secrets";
      };
    };

    wg-private-key = secret "wg-private-key";
    nix-serve-private-key = secret "nix-serve-private-key";
in
{
  meta = {
    description = "Test infrastructure";
    specialArgs = { inherit infrastructure; };
  };
  dev-01 = { ... }: {
    deployment.keys = wg-private-key "dev-01" // nix-serve-private-key "dev-01";
    workstation.user = "demo";
  };
  dev-02 = { ... }: {
    deployment.keys = wg-private-key "dev-02" // nix-serve-private-key "dev-02";
    workstation.user = "demo";
  };
  homepage-02 = { ... }: {
    deployment.keys = wg-private-key "homepage-02";
  };
  homepage-03 = { ... }: {
    deployment.keys = wg-private-key "homepage-03" // nix-serve-private-key "homepage-03";
  };
}
