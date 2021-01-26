{ pkgs, ... }:
{

  home = {
    packages = with pkgs; [
      bat
      cachix
      file
      glow
      gnumake
      httpie
      jq
      niv
      nix-prefetch-github
      shellcheck
      tree
      posix-toolbox.git-bubbles
      posix-toolbox.git-checkout-log
      posix-toolbox.git-ps1
      posix-toolbox.ls-colors
      posix-toolbox.wait-tcp
      nix-linter
    ];

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  programs = {

    bash = {
      enable = true;
      shellAliases = {
        glow = "glow -p";
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
      plugins = with pkgs.vimPlugins;
        let neovim-ghcid = pkgs.vimUtils.buildVimPlugin {
              name = "ghcid";
              src = (pkgs.fetchFromGitHub {
                owner = "ndmitchell";
                repo = "ghcid";
                rev = "5d7f859bc6dd553bdf93e6453391353cf310e232";
                sha256 = "1gyasmk6k2yqlkny27wnc1fn2khphgv400apfh1m59pzd9mdgsc2";
              }) + "/plugins/nvim";
            };
         in [
              gruvbox
              vim-airline
              vim-autoformat
              vim-nix
              vim-polyglot
              neovim-ghcid
            ];
      extraConfig = ''
          colorscheme gruvbox

          set tabstop=2
          set shiftwidth=2

          set cursorline
          set laststatus=2 " enable lightline

          "-- Edition ------------
          syn on
          set hls
          set nu
          set et

          " Cancel last search command
          nmap <silent> ,, :nohlsearch<CR>

          " Trigger autoformat on ',k'
          noremap ,k :Autoformat<CR>

          " Lignes autour du curseur
          set so=7

          set colorcolumn=80
        '';
    };

    git = {
      enable = true;
      userName = "Frédéric Menou";
      userEmail = "frederic.menou@gmail.com";
      aliases = {
        st = "status -sb";
        plog = "log --oneline --decorate --graph";
        slog = "log --format=short --decorate --graph";
        qu  = "log HEAD@{u}... --oneline --decorate --graph --boundary";
        qus = "log HEAD@{u}... --oneline --decorate --graph --boundary --stat";
        quc = "log HEAD@{u}..  --oneline --decorate --graph";
        qux = "log HEAD@{u}..  --oneline --decorate --graph            --stat";
        pq  = "log HEAD@{u}... --oneline --decorate --graph --patch";
        pqr = "log HEAD@{u}... --oneline --decorate         --patch --reverse";
        review = "rebase -i --autosquash";
        rework = "rebase -i --autosquash --autostash";
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
