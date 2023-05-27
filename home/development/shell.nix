{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      bat
      file
      tree
    ];

    sessionVariables = {
      NIX_SHELL_PRESERVE_PROMPT = 1;
    };
  };

  programs = {

    bash = {
      enable = true;
      shellAliases = {
        glow = "${pkgs.glow}/bin/glow -p";
      };
      initExtra = ''
        source ${pkgs.posix-toolbox.ls-colors}/share/ls-colors/bash.sh
        if [ -r "$HOME/.private/bash_aliases" ]; then source "$HOME/.private/bash_aliases"; fi
      '';
    };

    htop = {
      enable = true;
      settings = {
        highlight_base_name = 1;
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
      fonts = [ "xft:Monospace:pixelsize=10" ];
    };

    direnv.enable = true;
  };

  xsession.windowManager.i3.config.terminal = "${pkgs.rxvt-unicode-unwrapped}/bin/urxvt -e ${pkgs.tmux}/bin/tmux";

}
