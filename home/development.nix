{ pkgs, ... }:

{
  imports = [
    development/git.nix
  ];

  home = {
    packages = with pkgs; [
      bat
      file
      gnumake
      httpie
      jq
      shellcheck
      tree
      posix-toolbox.ls-colors
      posix-toolbox.wait-tcp
    ];

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  programs = {

    bash = {
      enable = true;
      shellAliases = {
        glow = "${pkgs.glow}/bin/glow -p";
        ":e" = "vim";
      };
      initExtra = ''
        source $HOME/.nix-profile/share/ls-colors/bash.sh
      '';
    };

    htop.enable = true;

    powerline-go = {
      enable = false; # I prefer my old git-ps1 for now
      settings = {
        hostname-only-if-ssh = true;
        modules-right = "nix-shell";
      };
    };

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

    tmux = {
      enable = true;
      keyMode = "vi";
      shortcut = "a";
      escapeTime = 0;
      plugins = with pkgs.tmuxPlugins; [
        continuum
        prefix-highlight
        sysstat
        tmux-colors-solarized
      ];
    };

    urxvt = {
      enable = true;
    };
  };

}
