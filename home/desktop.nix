{ config, lib, pkgs, ... }:

let palette = import ./palette.nix;

    inherit (import ./fonts.nix { baseSize = config.desktop.fontSize; }) roboto toGTK;
in
  {
    imports = [
      desktop/firefox.nix
      desktop/notifications.nix
      desktop/brightness.nix
      desktop/audio.nix
      desktop/wifi.nix
      desktop/polybar.nix
      desktop/screenlocker.nix
      desktop/redshift.nix
      desktop/random-background.nix
      desktop/picom.nix
      desktop/i3.nix
    ];

    options = with lib; {
      desktop.fontSize = mkOption {
        type = types.int;
        default = 9;
      };
      desktop.virtual-machine = mkOption {
        type = types.bool;
        default = false;
      };

      desktop.mainColor = mkOption {
        type = types.str;
        description = ''
          Color in hexadecimal form
        '';
        example = "#ff0000";
      };

      desktop.disabledColor = mkOption {
        type = types.str;
        description = ''
          Color in hexadecimal form
        '';
        default = "#cccccc";
        example = "#cccccc";
      };

      desktop.warnColor = mkOption {
        type = types.str;
        description = ''
          Color in hexadecimal form
        '';
        default = "#ffc3c3";
        example = "#ffc3c3";
      };

      desktop.activeColor = mkOption {
        type = types.str;
        description = ''
          Color in hexadecimal form
        '';
        default = "#afd6ff";
        example = "#afd6ff";
      };
    };

    config = {
      home.packages =
        if config.desktop.virtual-machine
        then [ pkgs.roboto pkgs.gnome.nautilus ]
        else [ pkgs.roboto pkgs.gnome.nautilus pkgs.networkmanager ];

      fonts.fontconfig.enable = true;

      gtk =
        let gtk2ExtraConfig = {
              gtk-button-images = 1;
              gtk-cursor-theme-name = "breeze_cursors";
              gtk-enable-animations = 1;
              gtk-fallback-icon-theme = "hicolor";
              gtk-menu-images = 1;
              gtk-primary-button-warps-slider = 0;
              gtk-toolbar-style = "GTK_TOOLBAR_BOTH_HORIZ";
            };
            gtk3ExtraConfig = gtk2ExtraConfig // {
              gtk-application-prefer-dark-theme = 1;
              gtk-decoration-layout = "icon:close";
            };
            formatGtk2Option = n: v:
              let
                isConstant = v: builtins.match "([A-Z_ ]*)" v == [ v ];
                v' = if lib.isBool v then
                  (if v then "true" else "false")
                else if lib.isString v && isConstant v then
                  v
                else if lib.isString v then
                  ''"${v}"''
                else
                  toString v;
              in "${n}=${v'}";
            toGTK2 = config : lib.concatStringsSep "\n" (lib.mapAttrsToList formatGtk2Option config);

         in {
              enable = true;
              font.name = toGTK roboto;
              theme = {
                package = pkgs.breeze-gtk;
                name = "Breeze";
              };
              iconTheme = {
                package = pkgs.papirus-icon-theme;
                name = "papirus-icon-theme";
              };
              gtk2.extraConfig = toGTK2 gtk2ExtraConfig;
              gtk3.extraConfig = gtk3ExtraConfig;
              gtk3.extraCss = "@import 'colors.css';";
            };

      xdg.configFile."gtk-3.0/colors.css".text = builtins.readFile desktop/colors.css;


      xresources.properties = with palette; {
        "*.foreground"  = special.foreground;
        "*.background"  = special.background;
        "*.cursorColor" = special.cursorColor;

        "*.color0"  = mate.black;
        "*.color1"  = mate.red;
        "*.color2"  = mate.green;
        "*.color3"  = mate.yellow;
        "*.color4"  = mate.blue;
        "*.color5"  = mate.magenta;
        "*.color6"  = mate.cyan;
        "*.color7"  = mate.white;
        "*.color8"  = vivid.black;
        "*.color9"  = vivid.red;
        "*.color10" = vivid.green;
        "*.color11" = vivid.yellow;
        "*.color12" = vivid.blue;
        "*.color13" = vivid.magenta;
        "*.color14" = vivid.cyan;
        "*.color15" = vivid.white;
      };
    };
  }
