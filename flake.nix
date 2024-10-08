{
  description = "Personal infrastructure & Home Manager configuration";

  inputs = {
    # nix package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    previous.url = "github:nixos/nixpkgs/nixos-22.11";

    # personal projects
    personal-homepage.url = "github:ptitfred/personal-homepage";
    ptitfred-haddocset.url = "github:ptitfred/haddocset";
    ptitfred-haddocset.flake = false;
    ptitfred-posix-toolbox .url = "github:ptitfred/posix-toolbox";

    # external dependencies
    colmena.url = "github:zhaofengli/colmena";
    easy-purescript-nix.url = "github:justinwoo/easy-purescript-nix";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nil.url = "github:oxalica/nil";
    nix-serve-ng.url = "github:aristanetworks/nix-serve-ng";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    power-theme.url = "github:wfxr/tmux-power";
    power-theme.flake = false;
    scram-sha-256.url = "github:supercaracal/scram-sha-256";
    scram-sha-256.flake = false;
    spago2nix.url = "github:justinwoo/spago2nix";
    spago2nix.inputs.easy-purescript-nix.follows = "easy-purescript-nix";
    spago2nix.inputs.nixpkgs.follows = "previous"; # FIXME get back to 23.05 once spago2nix drop nodejs-14
    wgsl-analyzer.url = "github:wgsl-analyzer/wgsl-analyzer";
  };

  outputs = inputs:
    let system = "x86_64-linux";

        previous-pkgs = import inputs.previous { inherit system; };

        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.personal-homepage.overlays.default
            (_: _: { inherit (tools) backgrounds; })
            (_: _: { nix-linter = previous-pkgs.nix-linter; })
          ];
        };

        colmena = pkgs.callPackage ./hive { inherit inputs; };
        lib = pkgs.callPackage ./lib.nix {} // { inherit (home) mkHomeConfiguration; };
        home = pkgs.callPackage ./home { inherit inputs system; };

        tools =
          helpers.dropOverrides (
            pkgs.callPackage ./tools { inherit inputs; } // home.tools
          );

        helpers = pkgs.callPackage ./helpers.nix {};
        tests = pkgs.callPackage ./tests { inherit colmena inputs lib; };

     in {
          inherit lib colmena;
          inherit (tests) homeConfigurations tests test-hive;

          apps.${system} = {
            lint = {
              type = "app";
              program = "${tools.lint}/bin/lint";
            };
          };

          checks.${system} =
            let local-lint = "${tools.lint}/bin/lint ${./.}";
            in { inherit (tests) tests; } // helpers.mkChecks { lint = local-lint; };

          devShells.${system}.default = pkgs.mkShell {
            buildInputs = [
              inputs.colmena.packages.${system}.colmena pkgs.pwgen
              tools.scram-sha-256
            ];
          };

          homeManagerModules = { inherit (home) workstation; };

          packages.${system} = helpers.bundleTools tools;
        };
}
