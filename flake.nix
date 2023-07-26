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
  };

  outputs = inputs@{ nixpkgs, previous, ... }:
    let system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; overlays = [ inputs.personal-homepage.overlays.default ]; };

        previous-pkgs = import previous { inherit system; };
        lint = pkgs.callPackage ./lint.nix { inherit (previous-pkgs) nix-linter; };
        pending-diff = pkgs.callPackage ./pending-diff.nix {};
        metadata = pkgs.callPackage ./metadata.nix {};

        lib = pkgs.callPackage ./lib.nix {};

        colmena = pkgs.callPackage ./infrastructure.nix { inherit inputs; };

        test-hive = lib.stackHives [ colmena (import tests/infra.nix) ];
        test-infra = (inputs.colmena.lib.makeHive (test-hive)).toplevel;

        tests =
          let mkNode = name: { inherit name; path = test-infra.${name}; };
              nodes = lib.nodesFromHive test-hive;
           in pkgs.linkFarm (test-hive.meta.description) (map mkNode nodes);
     in {
          devShells.${system}.default = pkgs.mkShell { buildInputs = [ inputs.colmena.packages.${system}.colmena pkgs.pwgen ]; };

          packages.${system} = { inherit pending-diff metadata; };

          apps.${system} = {
            lint = {
              type = "app";
              program = "${lint}/bin/lint";
            };
          };

          inherit lib colmena tests test-hive;
        };
}
