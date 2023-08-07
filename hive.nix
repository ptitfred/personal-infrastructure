{ pkgs, inputs, ... }:

{
  meta = {
    description = "Personal infrastructure";
    nixpkgs = pkgs;
    specialArgs = {
      inherit inputs;
    };
  };

  dev-01      = import hive/dev-01/system.nix;
  dev-02      = import hive/dev-02/system.nix;
  homepage-02 = import hive/homepage-02/system.nix;
  homepage-03 = import hive/homepage-03/system.nix;
}
