{
  description = "Personal infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=fa793b06f56896b7d1909e4b69977c7bf842b2f0";
    previous.url = "github:nixos/nixpkgs/nixos-22.11";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    personal-homepage.url = "github:ptitfred/personal-homepage?rev=69d49f9c14ef0868f0e23189178c08b4aece8bc1";

    nix-serve-ng.url = "github:aristanetworks/nix-serve-ng?rev=f3931b8120b1ca663da280e11659c745e2e9ad1b";

    home-manager.url = "github:nix-community/home-manager?rev=07c347bb50994691d7b0095f45ebd8838cf6bc38";
  };

  outputs = inputs@{ nixpkgs, previous, ... }:
    let system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; overlays = [ inputs.personal-homepage.overlays.default ]; };

        previous-pkgs = import previous { inherit system; };
        lint = pkgs.callPackage ./lint.nix { inherit (previous-pkgs) nix-linter; };
        pending-diff = pkgs.callPackage ./pending-diff.nix {};

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

          packages.${system} = { inherit pending-diff; };

          apps.${system} = {
            lint = {
              type = "app";
              program = "${lint}/bin/lint";
            };
          };

          inherit lib colmena tests test-hive;
        };
}
