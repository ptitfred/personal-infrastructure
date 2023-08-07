{
  description = "Personal infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    previous.url = "github:nixos/nixpkgs/nixos-22.11";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    personal-homepage.url = "github:ptitfred/personal-homepage";

    nix-serve-ng.url = "github:aristanetworks/nix-serve-ng";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager-base.url = "github:ptitfred/home-manager";

    scram-sha-256 = {
      url = "github:supercaracal/scram-sha-256";
      flake = false;
    };
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

     in {
          devShells.${system}.default = pkgs.mkShell { buildInputs = [ inputs.colmena.packages.${system}.colmena pkgs.pwgen ]; };

          packages.${system} = tools // { inherit scram-sha-256; };

          inherit lib colmena tests test-hive;
        };
}
