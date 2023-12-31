{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      purescript
      purescript-psa
      easy-ps.spago
      spago2nix
      easy-ps.purty
    ];
  };
}
