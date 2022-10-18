let fetchPackage = self: definition: path:
      self.callPackage (self.fetchFromGitHub (builtins.fromJSON (builtins.readFile definition)) + path) {};
in
 self: { ... }:
    let postgresql_12_postgis = self.postgresql_12.withPackages (p: [ p.postgis ]);
    in
      {
        posix-toolbox = fetchPackage self ./ptitfred-posix-toolbox.json "/nix/default.nix";
        haddocset = fetchPackage self ./ptitfred-haddocset.json "/default.nix";
        inherit postgresql_12_postgis;
      }
