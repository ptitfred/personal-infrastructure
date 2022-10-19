{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      cachix
      niv
      nix-linter
      nix-prefetch-github
      nvd
    ];
  };

  programs.neovim.plugins = [ pkgs.vimPlugins.vim-nix ];
}
