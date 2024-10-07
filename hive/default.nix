{ pkgs, inputs, ... }:

{
  meta = {
    description = "Personal infrastructure";
    nixpkgs = pkgs;
    specialArgs = {
      inherit inputs;
    };
  };

  dev-01      = import dev-01/system.nix;
  dev-02      = import dev-02/system.nix;
  homepage-02 = import homepage-02/system.nix;
  homepage-03 = import homepage-03/system.nix;
}
