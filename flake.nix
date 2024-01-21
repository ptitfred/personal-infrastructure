{
  description = "Personal infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    previous.url = "github:nixos/nixpkgs/nixos-22.11";

    colmena.url = "github:zhaofengli/colmena";
    # colmena.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-serve-ng.url = "github:aristanetworks/nix-serve-ng";

    home-manager-base.url = "github:ptitfred/home-manager";
    personal-homepage.url = "github:ptitfred/personal-homepage/post/retro-2023";

    scram-sha-256.url = "github:supercaracal/scram-sha-256";
    scram-sha-256.flake = false;
  };

  outputs = inputs@{ nixpkgs, previous, ... }:
    let system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; overlays = [ inputs.personal-homepage.overlays.default ]; };

        tools = pkgs.callPackages ./tools {
          inherit (previous.legacyPackages.${system}) nix-linter;
        };

        lib = pkgs.callPackage ./lib.nix {};

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
          vendorSha256 = "sha256-qNJSCLMPdWgK/eFPmaYBcgH3P6jHBqQeU4gR6kE/+AE=";
        };

        mkCheck = name: script:
          pkgs.runCommand name {} ''
            mkdir -p $out
            ${script}
          '';

        mkChecks = pkgs.lib.attrsets.mapAttrs mkCheck;

     in {
          devShells.${system}.default = pkgs.mkShell { buildInputs = [ inputs.colmena.packages.${system}.colmena pkgs.pwgen ]; };

          packages.${system} = tools // { inherit scram-sha-256; };

          inherit lib colmena tests test-hive;

          checks.${system} = { inherit tests; } // mkChecks { lint = "${tools.lint}/bin/lint ${./.}"; };
        };
}
