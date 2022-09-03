{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      cachix
      niv
      nix-prefetch-github
      nvd
    ];
  };

  programs.neovim.plugins = [ pkgs.vimPlugins.vim-nix ];
}
