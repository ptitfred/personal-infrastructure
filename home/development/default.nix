{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./neovim.nix
    ./git.nix
    ./haskell.nix
    ./tools.nix
  ];
}
