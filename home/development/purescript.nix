{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      purescript
      purescript-psa
      easy-ps.spago
      easy-ps.purty
    ];
  };
}
