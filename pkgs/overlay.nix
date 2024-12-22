final: prev:

with final.lib.path;

let load = directory:
      let version = builtins.fromJSON (builtins.readFile (append directory "version.json"));
       in overrides: final.callPackage (append directory "package.nix") (overrides // version);
 in {
      flake-updater = final.callPackage ./flake-updater {};
      matomo   = load ./matomo   {};
      obsidian = load ./obsidian { inherit (prev) obsidian; };

      backgrounds = final.callPackage ./backgrounds {};
    }
