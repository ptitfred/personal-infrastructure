{
  description = "Personal infrastructure & Home Manager configuration";

  inputs = {
    # package sets, currently on 24.11
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    previous.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Lix <https://lix.systems/add-to-config/>
    lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";

    # personal projects
    ptitfred-personal-homepage.url = "github:ptitfred/personal-homepage";
    ptitfred-haddocset.url = "github:ptitfred/haddocset";
    ptitfred-haddocset.flake = false;
    ptitfred-posix-toolbox.url = "github:ptitfred/posix-toolbox";
    ptitfred-posix-toolbox.inputs.home-manager.follows = "home-manager";

    # external dependencies
    colmena.url = "github:zhaofengli/colmena";
    easy-purescript-nix.url = "github:justinwoo/easy-purescript-nix";
    nil.url = "github:oxalica/nil";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    power-theme.url = "github:wfxr/tmux-power";
    power-theme.flake = false;
    scram-sha-256.url = "github:supercaracal/scram-sha-256";
    scram-sha-256.flake = false;
    wgsl-analyzer.url = "github:wgsl-analyzer/wgsl-analyzer";
  };

  outputs = inputs:
    let system = "x86_64-linux";

        previous-pkgs = import inputs.previous { inherit system; };

        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.lix-module.overlays.default
            inputs.ptitfred-posix-toolbox.overlays.linter
            (_: _: { nix-linter = previous-pkgs.nix-linter; })
            overlay
          ];
        };

        overlay = import pkgs/overlay.nix;

        colmena = pkgs.callPackage ./hive { inherit inputs; };
        home = pkgs.callPackage ./home { inherit inputs system; };

        lib = pkgs.callPackage ./lib { baseHive = colmena; } // { inherit (home) mkHomeConfiguration; };
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
              inputs.colmena.packages.${system}.colmena pkgs.pwgen
              tools.scram-sha-256
            ];
          };

          homeManagerModules = { inherit (home) workstation; };

          overlays.default = overlay;

          packages.${system} = helpers.bundleTools tools // {
            inherit (tests) integration-tests;
            inherit (pkgs) lix-updater matomo-updater obsidian-updater;
          };
        };
}
