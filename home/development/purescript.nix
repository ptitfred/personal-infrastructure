{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      purescript
      purescript-psa
      spago
      spago2nix
      easy-ps.purty
    ];
  };
}
