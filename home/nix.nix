{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      cachix
      niv
      nix-linter
      nix-prefetch-git
      nix-prefetch-github
      nvd
    ];
  };

  programs.neovim.plugins = [ pkgs.vimPlugins.vim-nix ];
}
