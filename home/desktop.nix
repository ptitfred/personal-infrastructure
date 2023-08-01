{ config, lib, pkgs, ... }:

let palette = import ./palette.nix;

    screenshot = pkgs.callPackage desktop/screenshot {};
    screenshotCmd = "${screenshot}/bin/screenshot";

    backgrounds = pkgs.callPackage desktop/backgrounds {};

    inherit (import ./fonts.nix { baseSize = config.desktop.fontSize; }) roboto toI3 toGTK;

    mkWorkspace = index: name: { inherit index name; };

    terminal      = mkWorkspace 1 "Terminal";
    web           = mkWorkspace 2 "Web";
    pro           = mkWorkspace 3 "Pro";
    chat          = mkWorkspace 4 "Chat";
    files         = mkWorkspace 5 "Files";
    documentation = mkWorkspace 6 "Documentation";
    system        = mkWorkspace 8 "Système";
    capture       = mkWorkspace 9 "Capture";
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

      desktop.spacing = mkOption {
        type = types.int;
        description = "";
        default = 10;
      };

      desktop.exec-on-login = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "sxhkd" ];
      };

      desktop.i3-extra-bindings = mkOption {
        type = types.attrsOf types.str;
        default = {};
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

      services = {
        picom = {
          enable = true;
          activeOpacity = 0.95;

          settings = {
            # blur is now configured here
          };
          # blur = false;

          inactiveOpacity = 0.93;
          menuOpacity = 0.95;
          opacityRules = [ "100:class_g *= 'firefox'" "100:class_g *= 'Zeal'"];
          vSync = false;
        };

        random-background = {
          enable = true;
          imageDirectory = backgrounds.outPath;
          interval = "20 minutes";
        };
      };

      xsession.windowManager.i3 =
        {
        enable = true;
        config =
          let font = toGTK roboto;

              workspaces =
                [ terminal
                  chat
                  pro
                  web
                  files
                  documentation
                  system
                  capture
                ];
              foldMap = function: builtins.foldl' (acc: value: acc // function value) {};
              concat = foldMap (x: x);
          in {
            bars = []; # we rely on polybar
            fonts = toI3 roboto;
            workspaceAutoBackAndForth = true;

            colors = {
              focused = lib.mkOptionDefault {
                border      = lib.mkForce palette.special.background;
                childBorder = lib.mkForce palette.special.background;
                indicator   = lib.mkForce config.desktop.mainColor;
                background = lib.mkForce palette.special.background;
                text = lib.mkForce config.desktop.mainColor;
              };
              unfocused = lib.mkOptionDefault {
                text = lib.mkForce palette.mate.white;
              };
            };

            gaps = {
              inner = config.desktop.spacing;
              smartBorders = "on";
            };

            keybindings =
              let modifier = config.xsession.windowManager.i3.config.modifier;
                  bindWorkspace = { index, name } : {
                    "${modifier}+${builtins.toString index}"       = "workspace number ${builtins.toString index}:${name}";
                    "${modifier}+Shift+${builtins.toString index}" = "move container to workspace number ${builtins.toString index}:${name}";
                  };
                  bindWorkspaces = foldMap bindWorkspace;
                  mkBindRelease = key: command: {
                    "--release ${modifier}+${key}" = "exec ${command}";
                  };
                  bindings = mkBindRelease "x"     screenshotCmd
                          // bindWorkspaces workspaces
                          // config.desktop.i3-extra-bindings;
               in lib.mkOptionDefault bindings;

            menu = "${pkgs.bemenu}/bin/bemenu-run -l 20 -p '>' -i --fn '${font}' -H 15 --hf '${config.desktop.mainColor}' --tf '${config.desktop.mainColor}'";

            startup =
              let onStart = command: { inherit command; always = true; notification = false; };
               in builtins.map onStart config.desktop.exec-on-login;

            assigns =
              let assignToWorkspace = {index, name} : assignments: { "${builtins.toString index}: ${name}" = assignments; };
               in concat
                    [ (assignToWorkspace files         [ { class = "^org.gnome.Nautilus$";       } ])
                      (assignToWorkspace capture       [ { class = "^.shutter-wrapped$";         } ])
                      (assignToWorkspace documentation [ { class = "^Zeal$";                     } ])
                      (assignToWorkspace system        [ { class = "^Com.github.stsdc.monitor$"; } ])
                    ];
          };
        extraConfig =
          ''
            for_window [class=".*"] title_format "  %title"
            for_window [class="(?i)nm-connection-editor"] floating enable, move position center
            exec i3-msg workspace ${toString terminal.index}:${terminal.name}
          '';
      };

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
