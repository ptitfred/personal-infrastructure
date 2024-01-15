{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.bash.shellAliases = {
    ":e" = "vim";
  };

  home.packages = [ pkgs.xclip pkgs.libxml2 ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = builtins.readFile ./neovim-config.vim;
    plugins =
      with pkgs.vimPlugins;
        [
          cmp-nvim-lsp
          gruvbox
          vim-airline
          vim-autoformat
          vim-polyglot
          vim-vsnip
          nvim-autopairs
          nvim-cmp
          nvim-lspconfig
          hover-nvim
          telescope-nvim
          telescope-fzf-native-nvim
        ];
  };
}
