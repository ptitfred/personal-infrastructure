{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      purescript
      easy-ps.spago
      easy-ps.purty
    ];
  };
}
