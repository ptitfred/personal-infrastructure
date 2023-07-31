{ config, pkgs, ... }:
{
  home.packages = [ pkgs.libnotify ];

  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "32x32";
        origin = "top-right";
        transparency = 5;
        frame_color = "#eceff1";
        font = "Roboto ${toString (config.desktop.fontSize + 1)}";
        corner_radius = 4;
        gap_size = 8;
      };

      urgency_low = rec {
        background = "#37474f";
        foreground = "#d4d7d9aa";
        frame_color = background;
        timeout = 5;
      };

      urgency_normal = rec {
        background = "#37474f";
        foreground = "#eceff1";
        frame_color = background;
        timeout = 10;
      };

      urgency_critical = rec {
        background = "#b8352c";
        foreground = "#eceff1";
        frame_color = background;
        timeout = 0;
      };
    };
  };
}
