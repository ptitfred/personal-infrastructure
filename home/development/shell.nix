{ config, pkgs, ... }:

let baseSize = config.desktop.fontSize;
    inherit (import ../fonts.nix { inherit baseSize; }) toXFT;
    patched-monospace = pkgs.callPackage ./patched-monospace.nix {};
 in

{
  home = {
    packages = with pkgs; [
      bat
      file
      tree
      noto-fonts-emoji
      patched-monospace
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
      package = pkgs.rxvt-unicode-emoji;
      fonts =
        let f = name: toXFT { inherit name; size = baseSize + 1; };
         in map f
              [
                "DejaVuSansM Nerd Font Mono Plus Font Awesome Plus Font Awesome Extension"
                "Material Symbols Outlined"
                "Noto Color Emoji"
              ];
      keybindings = {
        "Shift-Control-C" = "eval:selection_to_clipboard";
        "Shift-Control-V" = "eval:paste_clipboard";
      };
      iso14755 = false;
    };

    direnv.enable = true;
  };

  xsession.windowManager.i3.config.terminal =
    "${config.programs.urxvt.package}/bin/urxvt -e ${config.programs.tmux.package}/bin/tmux";
}
