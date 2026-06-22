{ config, lib, pkgs, ... }:

let assets = import ../../assets { baseSize = config.desktop.fontSize; };
 in
{
  config = lib.mkIf (config.desktop.windowManager == "hyprland") {
    programs.kitty.enable = true; # required for the default Hyprland config
    programs.kitty.settings = with assets.palette; {
      mark1_foreground = special.foreground;
      mark1_background = special.background;
      cursor           = special.cursorColor;
      cursor_shape     = "block";

      color0  = mate.black;
      color1  = mate.red;
      color2  = mate.green;
      color3  = mate.yellow;
      color4  = mate.blue;
      color5  = mate.magenta;
      color6  = mate.cyan;
      color7  = mate.white;
      color8  = vivid.black;
      color9  = vivid.red;
      color10 = vivid.green;
      color11 = vivid.yellow;
      color12 = vivid.blue;
      color13 = vivid.magenta;
      color14 = vivid.cyan;
      color15 = vivid.white;

      startup_session = let file = pkgs.writeText "session.conf" ''
        launch ${config.programs.tmux.package}/bin/tmux
      ''; in "${file}";

      momentum_scroll = 0;
    };

    wayland.windowManager.hyprland.settings = {
      "$terminal" = "kitty";
    };
  };
}
