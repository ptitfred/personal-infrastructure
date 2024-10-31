{ callPackage }:

callPackage ./package.nix (builtins.fromJSON (builtins.readFile ./version.json))
