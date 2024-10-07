{
  description = "Personal infrastructure & Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    previous.url = "github:nixos/nixpkgs/nixos-22.11";

    colmena.url = "github:zhaofengli/colmena";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-serve-ng.url = "github:aristanetworks/nix-serve-ng";

    personal-homepage.url = "github:ptitfred/personal-homepage";

    scram-sha-256.url = "github:supercaracal/scram-sha-256";
    scram-sha-256.flake = false;

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ptitfred-posix-toolbox .url = "github:ptitfred/posix-toolbox";

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

    power-theme = {
      url = "github:wfxr/tmux-power";
      flake = false;
    };

    nil.url = "github:oxalica/nil";

    wgsl-analyzer.url = "github:wgsl-analyzer/wgsl-analyzer";
  };

  outputs = inputs@{ nixpkgs, previous, ... }:
    let system = "x86_64-linux";

        previous-pkgs = import previous { inherit system; };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.personal-homepage.overlays.default
            (_: _: { inherit (tools) backgrounds; })
            (_: _: { nix-linter = previous-pkgs.nix-linter; })
          ];
        };

        home = pkgs.callPackage ./home { inherit inputs system; };

        tools =
          helpers.dropOverrides (
            pkgs.callPackage ./tools { inherit inputs; } // home.tools
          );

        helpers = pkgs.callPackage ./helpers.nix {};

        lib = pkgs.callPackage ./lib.nix {} // { inherit (home) mkHomeConfiguration; };

        colmena = pkgs.callPackage ./hive.nix { inherit inputs; };

        test-hive = lib.stackHives [ colmena (import tests/infra.nix) ];
        test-infra = (inputs.colmena.lib.makeHive test-hive).toplevel;

        tests =
          let mkNode = name: { inherit name; path = test-infra.${name}; };
              nodes = lib.nodesFromHive test-hive;
           in pkgs.linkFarm test-hive.meta.description (map mkNode nodes);
     in {
          devShells.${system}.default = pkgs.mkShell {
            buildInputs = [
              inputs.colmena.packages.${system}.colmena pkgs.pwgen
              tools.scram-sha-256
            ];
          };

          homeManagerModules = { inherit (home) workstation; };

          homeConfigurations.test-virtual-machine = home.mkHomeConfiguration tests/virtual-machine.nix;
          homeConfigurations.test-laptop          = home.mkHomeConfiguration tests/laptop.nix;

          packages.${system} = helpers.bundleTools tools;

          inherit lib colmena tests test-hive;

          checks.${system} =
            let local-lint = "${tools.lint}/bin/lint ${./.}";
            in { inherit tests; } // helpers.mkChecks { lint = local-lint; };

          apps.${system} = {
            lint = {
              type = "app";
              program = "${tools.lint}/bin/lint";
            };
          };
        };
}
