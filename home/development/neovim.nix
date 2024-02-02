{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.bash.shellAliases = {
    ":e" = "vim";
  };

  home.packages = [
    pkgs.xclip
    pkgs.libxml2
    pkgs.gh
    pkgs.marksman
    pkgs.lua-language-server
    pkgs.nil
    pkgs.nodePackages.bash-language-server
    pkgs.shellcheck
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      ${builtins.readFile ./neovim-config.vim}
      lua << EOF
        ${builtins.readFile ./neovim-config.lua}
      EOF
    '';
    plugins =
      with pkgs.vimPlugins;
        [
          cmp-buffer
          cmp-cmdline
          cmp-git
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          cmp-omni
          cmp-path
          cmp-spell
          comment-nvim
          gruvbox
          vim-airline
          vim-autoformat
          vim-polyglot
          vim-vsnip
          lspkind-nvim
          nvim-autopairs
          nvim-cmp
          nvim-lspconfig
          hover-nvim
          telescope-nvim
          telescope-fzf-native-nvim
          telescope-lsp-handlers-nvim
          telescope-ui-select-nvim
        ];
  };
}
