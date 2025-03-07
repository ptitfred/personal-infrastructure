final: prev:

with final.lib.path;

let load = directory:
      let version = builtins.fromJSON (builtins.readFile (append directory "version.json"));
       in overrides: final.callPackage (append directory "package.nix") (overrides // version);

 in {
      backgrounds = final.callPackage ./backgrounds {};

      flake-updater    = final.callPackage ./flake-updater      {};
      generic-updater  = final.callPackage ./generic-updater    {};
      lix-updater      = final.callPackage ./lix-updater        {};
      matomo-updater   = final.callPackage matomo/updater.nix   {};
      obsidian-updater = final.callPackage obsidian/updater.nix {};

      rxvt-unicode-emoji = final.callPackage ./rxvt-unicode-emoji { inherit (prev) rxvt-unicode-emoji; };

      matomo   = load ./matomo   {};
      obsidian = load ./obsidian { inherit (prev) obsidian; };
    }
