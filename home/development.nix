{ pkgs, ... }:

{
  imports = [
    development/shell.nix
    development/git.nix
  ];

  home = {
    packages = with pkgs; [
      gnumake
      httpie
      jq
      shellcheck
      posix-toolbox.wait-tcp
    ];

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  programs = {

    neovim = {
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
  };

}
