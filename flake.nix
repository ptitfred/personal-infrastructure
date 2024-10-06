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

  outputs = inputs@{ nixpkgs, previous, home-manager, ... }:
    let system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.personal-homepage.overlays.default
            (_: _: { inherit (tools) backgrounds; })
          ];
        };

        previous-pkgs = import previous { inherit system; };
        lint = previous-pkgs.callPackage ./lint.nix {};

        workstation =
          { ... }:
          {
            imports = [ ./workstation.nix ];
            nixpkgs.overlays = [
              inputs.ptitfred-posix-toolbox.overlay
              inputs.nil.overlays.nil
              inputs.wgsl-analyzer.overlays.default
              hm-overlay
            ];
          };

        hm-overlay = self: previous: {
          # 22.11 still available when needed
          previous = inputs.previous.legacyPackages.${system};

          haddocset = self.callPackage inputs.ptitfred-haddocset {};
          postgresql_12_postgis = self.postgresql_12.withPackages (p: [ p.postgis ]);
          inherit (previous-pkgs) nix-linter;
          inherit (inputs.spago2nix.packages.${system}) spago2nix;
          easy-ps = inputs.easy-purescript-nix.packages.${system};
          tmuxPlugins = previous.tmuxPlugins // {
            power-theme = previous.tmuxPlugins.power-theme.overrideAttrs (_: { src = inputs.power-theme; });
          };
        };

        hm-pkgs = import nixpkgs { inherit system; };

        tools =
          dropOverrides (
            pkgs.callPackage ./tools {} //
            hm-pkgs.callPackage home/tools.nix {}
          );

        dropOverrides =
          let dropOverride = name: _: ! builtins.elem name [ "override" "overrideDerivation"];
           in pkgs.lib.attrsets.filterAttrs dropOverride;

        bundle-tools = tools:
          let default = pkgs.symlinkJoin { name = "tools"; paths = builtins.attrValues tools; };
          in tools // { inherit default; };

        lib = pkgs.callPackage ./lib.nix {} // { inherit mkHomeConfiguration; };

        colmena = pkgs.callPackage ./hive.nix { inherit inputs; };

        test-hive = lib.stackHives [ colmena (import tests/infra.nix) ];
        test-infra = (inputs.colmena.lib.makeHive test-hive).toplevel;

        tests =
          let mkNode = name: { inherit name; path = test-infra.${name}; };
              nodes = lib.nodesFromHive test-hive;
           in pkgs.linkFarm test-hive.meta.description (map mkNode nodes);

        scram-sha-256 = pkgs.buildGoModule {
          name = "scram-sha-256";
          src = inputs.scram-sha-256;
          vendorHash = "sha256-HjyD30RFf5vnZ8CNU1s3sTTyCof1yD8cdVWC7cLwjic=";
        };

        mkCheck = name: script:
          pkgs.runCommand name {} ''
            mkdir -p $out
            ${script}
          '';

        mkChecks = pkgs.lib.attrsets.mapAttrs mkCheck;

        mkHomeConfiguration = module:
          home-manager.lib.homeManagerConfiguration {
            pkgs = hm-pkgs;
            modules = [ workstation module ];
          };

     in {
          devShells.${system}.default = pkgs.mkShell {
            buildInputs = [
              inputs.colmena.packages.${system}.colmena pkgs.pwgen
            ];
          };

          homeManagerModules = { inherit workstation; };

          homeConfigurations.test-virtual-machine = mkHomeConfiguration tests/virtual-machine.nix;
          homeConfigurations.test-laptop          = mkHomeConfiguration tests/laptop.nix;

          packages.${system} = bundle-tools tools // { inherit scram-sha-256; };

          inherit lib colmena tests test-hive;

          checks.${system} =
            let local-lint = "${lint}/bin/lint ${./.}";
            in { inherit tests; } // mkChecks { lint = local-lint; };

          apps.${system} = {
            lint = {
              type = "app";
              program = "${lint}/bin/lint";
            };
          };
        };
}
