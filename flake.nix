{
  description = "Personal infrastructure & Home Manager configuration";

  inputs = {
    # package sets, currently on 25.11
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    previous.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # personal projects
    ptitfred-personal-homepage.url = "github:ptitfred/personal-homepage";
    ptitfred-haddocset.url = "github:ptitfred/haddocset";
    ptitfred-haddocset.flake = false;
    ptitfred-posix-toolbox.url = "github:ptitfred/posix-toolbox";
    ptitfred-posix-toolbox.inputs.home-manager.follows = "home-manager";

    # external dependencies
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";
    easy-purescript-nix.url = "github:justinwoo/easy-purescript-nix";
    nil.url = "github:oxalica/nil";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    power-theme.url = "github:wfxr/tmux-power";
    power-theme.flake = false;
    scram-sha-256.url = "github:supercaracal/scram-sha-256";
    scram-sha-256.flake = false;
  };

  outputs = inputs:
    let system = "x86_64-linux";

        previous-pkgs = import inputs.previous { inherit system; };

        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            # See https://lix.systems/add-to-config/#advanced-change
            lix-overlay

            inputs.ptitfred-posix-toolbox.overlays.linter
            inputs.colmena.overlays.default
            # (final: _: { colmena = (inputs.colmena.packages.${system}.colmena).override({ inherit (final) nix-eval-jobs; }); })
            (_: _: { nix-linter = previous-pkgs.nix-linter; })
            overlay
          ];
        };

        lix-overlay = import pkgs/lix-overlay.nix;
        overlay = import pkgs/overlay.nix;

        colmena = pkgs.callPackage ./hive { inherit inputs; };
        home = pkgs.callPackage ./home { inherit inputs system; };

        lib = pkgs.callPackage ./lib { baseHive = colmena; colmenaLib = inputs.colmena.lib; } // { inherit (home) mkHomeConfiguration; };
        helpers = pkgs.callPackage lib/helpers.nix {};

        tools =
          helpers.dropOverrides (
            pkgs.callPackage ./tools { inherit inputs; } // home.tools
          );
        tests = pkgs.callPackage ./tests { inherit inputs lib; };

     in {
          inherit lib colmena;
          inherit (tests) homeConfigurations tests test-hive;

          apps.${system} = {
            lint = {
              type = "app";
              program = "${pkgs.posix-toolbox.nix-linter}/bin/nix-linter";
            };
          };

          checks.${system} =
            let local-lint = "${pkgs.posix-toolbox.nix-linter}/bin/nix-linter ${./.}";
            in { inherit (tests) tests; } // helpers.mkChecks { lint = local-lint; };

          devShells.${system}.default = pkgs.mkShell {
            buildInputs = [
              pkgs.colmena
              pkgs.pwgen
              tools.scram-sha-256
              pkgs.lixPackageSets.stable.lix
            ];
          };

          homeManagerModules = { inherit (home) workstation; };

          overlays.default = overlay;

          packages.${system} = helpers.bundleTools tools // {
            inherit (tests) integration-tests;
            inherit (pkgs) obsidian-updater;
          };
        };
}
