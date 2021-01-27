{ pkgs, ... }:
{

  home = {
    packages = with pkgs; [
      bat
      file
      gnumake
      httpie
      jq
      shellcheck
      tree
      posix-toolbox.git-bubbles
      posix-toolbox.git-checkout-log
      posix-toolbox.git-ps1
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
      };
      initExtra = ''
        source $HOME/.nix-profile/share/ls-colors/bash.sh
        source $HOME/.nix-profile/share/posix-toolbox/git-ps1
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

    git = {
      enable = true;
      userName = "Frédéric Menou";
      userEmail = "frederic.menou@gmail.com";
      aliases = rec {
        st = "status -sb";
        plog = "log --oneline --decorate --graph";
        slog = "log --format=short --decorate --graph";
        qu  = "log HEAD@{u}... --oneline --decorate --graph --boundary";
        qus = qu + " --stat";
        quc = "log HEAD@{u}..  --oneline --decorate --graph";
        qux = quc + " --stat";
        pq  = "log HEAD@{u}... --oneline --decorate --graph --patch";
        pqr = "log HEAD@{u}... --oneline --decorate         --patch --reverse";
        review = "rebase -i --autosquash";
        rework = review + " --autostash";
        pdiff = "diff -w --word-diff=color";
        pshow = "show -w --word-diff=color";
        fop = "fetch --prune origin";
        ls-others = "ls-files -o --exclude-standard";
      };
      extraConfig = {
        pull.rebase = true;
        bubbles.remote-name = "mine";
      };
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
