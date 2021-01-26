{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      cachix
      niv
      nix-prefetch-github
      nix-linter
    ];
  };

  programs.neovim.plugins = [ pkgs.vimPlugins.vim-nix ];
}
