{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.bash.shellAliases = {
    ":e" = "vim";
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = builtins.readFile ./neovim-config.vim;
    plugins =
      with pkgs.vimPlugins;
        [
          gruvbox
          vim-airline
          vim-autoformat
          vim-polyglot
        ];
  };
}
