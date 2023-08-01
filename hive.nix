{ pkgs, inputs, ... }:

{
  meta = {
    description = "Personal infrastructure";
    nixpkgs = pkgs;
    specialArgs = {
      inherit inputs;
    };
  };

  dev-01      = import ./dev-01.nix;
  dev-02      = import ./dev-02.nix;
  homepage-02 = import ./homepage-02.nix;
  homepage-03 = import ./homepage-03.nix;
}
