{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    previous.url = "github:nixos/nixpkgs/nixos-22.11";

    ptitfred-posix-toolbox = {
      url = "github:ptitfred/posix-toolbox";
      flake = false;
    };

    ptitfred-haddocset = {
      url = "github:ptitfred/haddocset";
      flake = false;
    };

    easy-purescript-nix.url = "github:justinwoo/easy-purescript-nix";

    spago2nix = {
      url = "github:justinwoo/spago2nix";
      inputs.nixpkgs.follows = "previous"; # FIXME get back to 23.05 once spago2nix drop nodejs-14
      inputs.easy-purescript-nix.follows = "easy-purescript-nix";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, previous, ... }:
    let
      system = "x86_64-linux";

      personal-overlay = self: _: {
        # 22.11 still available when needed
        previous = inputs.previous.legacyPackages.${system};

        posix-toolbox = self.callPackage "${inputs.ptitfred-posix-toolbox}/nix/default.nix" {};
        haddocset = self.callPackage "${inputs.ptitfred-haddocset}/default.nix" {};
        postgresql_12_postgis = self.postgresql_12.withPackages (p: [ p.postgis ]);
        inherit (previous-pkgs) nix-linter;
      };

      purescript-overlay = _: _: {
        inherit (inputs.spago2nix.packages.${system}) spago2nix;
        easy-ps = inputs.easy-purescript-nix.packages.${system};
      };

      loadPackages = overlays: import nixpkgs {
        inherit system;
        overlays = [ personal-overlay purescript-overlay ] ++ overlays;
      };

      previous-pkgs = import previous { inherit system; };
      lint = previous-pkgs.callPackage ./lint.nix {};
      laptop = ./laptop.nix;

    in rec {
      homeManagerModules = { inherit laptop; };

      homeConfigurationHelper = { overlays ? [], modules ? [], extraSpecialArgs ? {} } : home-manager.lib.homeManagerConfiguration {
        inherit extraSpecialArgs;
        pkgs = loadPackages overlays;
        modules = modules ++ [ laptop ];
      };

      homeConfigurations.test = homeConfigurationHelper {
        modules = [
          tests/home.nix
        ];
      };

      packages.${system} =
        let pkgs = loadPackages [];
            tools = {
              screenshot         = pkgs.callPackage home/desktop/screenshot          {};
              backgrounds        = pkgs.callPackage home/desktop/backgrounds         {};
              toggle-redshift    = pkgs.callPackage home/desktop/toggle-redshift.nix {};
              locker             = pkgs.callPackage home/desktop/locker.nix          {};
              focus-by-classname = pkgs.callPackage home/desktop/focus-by-classname  {};
            };
         in tools // {
              default = pkgs.linkFarm "tools" tools;
            };

      apps.${system} = {
        lint = {
          type = "app";
          program = "${lint}/bin/lint";
        };
      };
    };
}
