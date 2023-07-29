{ config, lib, pkgs, ... }:

let lockCmd = "${pkgs.posix-toolbox.i3-screen-locker}/bin/i3-screen-locker";
    bottom = true;

    palette = import ./palette.nix;

    screenshot = pkgs.callPackage desktop/screenshot {};
    screenshotCmd = "${screenshot}/bin/screenshot";

    backgrounds = pkgs.callPackage desktop/backgrounds {};

    baseSize = config.desktop.fontSize;

    inherit (import ./fonts.nix { inherit baseSize; }) roboto toPolybar toI3 toGTK;

    editConnectionsOnClick = label:
      "%{A1:${pkgs.networkmanagerapplet}/bin/nm-connection-editor:}${label}%{A}";
in
  {
    imports = [
      desktop/firefox.nix
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

      desktop.location.latitude = mkOption {
        type = types.str;
        description = ''
          Latitude to use for redshift.
        '';
      };
      desktop.location.longitude = mkOption {
        type = types.str;
        description = ''
          Longitude to use for redshift.
        '';
      };

      desktop.mainColor = mkOption {
        type = types.str;
        description = ''
          Color in hexadecimal form, form instance: '#ff0000'.
        '';
      };

      desktop.spacing = mkOption {
        type = types.int;
        description = "";
        default = 10;
      };

      desktop.battery.full-at = mkOption {
        type = types.int;
        default = 99;
      };

      desktop.battery.low-at = mkOption {
        type = types.int;
        default = 10;
      };

      desktop.battery.battery = mkOption {
        type = types.str;
        example = "BAT1";
      };

      desktop.battery.adapter = mkOption {
        type = types.str;
        example = "ADP1";
      };

      desktop.backlight.card = mkOption {
        type = types.str;
        default = "intel_backlight";
      };
    };

    config = {
      home.packages =
        if config.desktop.virtual-machine
        then [ pkgs.roboto pkgs.material-symbols pkgs.gnome.nautilus ]
        else [ pkgs.roboto pkgs.material-symbols pkgs.gnome.nautilus pkgs.networkmanager ];

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
        polybar = {
          enable = true;
          package = pkgs.polybarFull;
          config = {
            "bar/main" = {
              font-0 = toPolybar roboto + ";2";
              font-1 = "Material Symbols Outlined:size=${toString (baseSize -1)};2";
              inherit bottom;
              height = "${toString (builtins.ceil (baseSize * 2.2))}pt";
              radius = 6;
              width = "100%";
              modules-left = "i3";
              modules-right = if config.desktop.virtual-machine then "memory storage date" else "wifi memory storage backlight battery date";
              background = "#99000000";
              padding = 3;
              border-size = config.desktop.spacing;
              border-top-size    = if bottom then 0 else config.desktop.spacing;
              border-bottom-size = if bottom then config.desktop.spacing else 0;
              separator = "|";
              separator-foreground = config.desktop.mainColor;
              module-margin = 2;
              locale = "fr_FR.UTF-8";
              tray-position = "none";
              line-size = 3;
              cursor-click  = "pointer";
              cursor-scroll = "ns-resize";
            };

            "module/memory" = {
              type = "internal/memory";
              interval = "0.5";
              format = "<label>";
              label = "%{T2}%{T-} %free%";
            };

            "module/storage" = {
              type = "internal/fs";
              mount-0 = "/";
              format-mounted = "<label-mounted>";
              label-mounted = "%{T2}%{T-} %mountpoint% %free%";
            };

            "module/i3" = let padding = 2; in {
              type = "internal/i3";
              strip-wsnumbers = true;
              label-focused = "%name%";
              label-focused-foreground = "#ffffff";
              label-focused-background = "#3f3f3f";
              label-focused-underline = config.desktop.mainColor; # "#fba922";
              label-focused-padding = padding;
              label-unfocused = "%name%";
              label-unfocused-padding = padding;
              label-urgent = "%name% [%index%]";
              label-urgent-foreground = palette.vivid.white;
              label-urgent-background = palette.mate.cyan;
              label-urgent-padding = padding;
              label-separator = "|";
              label-separator-foreground = config.desktop.mainColor;
              label-separator-padding = 1;
              wrapping-scroll = false;
            };

            "module/date" = {
              type = "internal/date";
              internal = 5;
              date = "%Y-%m-%d";
              time = "%H:%M:%S";
              label = "%date%  %time%";
            };
          } // (
            if config.desktop.virtual-machine
            then {}
            else
              {
                "module/battery" = {
                  type = "internal/battery";
                  format-charging    = "%{T2}<animation-charging>%{T-} <label-charging>";
                  format-discharging = "%{T2}<ramp-capacity>%{T-} <label-discharging>";
                  label-charging     = "%percentage%% (%time% +%consumption%W)";
                  label-discharging  = "%percentage%% (%time% -%consumption%W)";
                  label-low          = "%{T2}%{T-} %percentage%% (%time% -%consumption%W)";
                  label-full         = "%{T2}%{T-} Max";

                  # So sad we can't have ramps specifics for charging and discharging
                  animation-charging-0 = "";
                  animation-charging-1 = "";
                  animation-charging-2 = "";
                  animation-charging-3 = "";
                  animation-charging-4 = "";
                  animation-charging-5 = "";
                  animation-charging-framerate = 750;

                  ramp-capacity-0 = "";
                  ramp-capacity-1 = "";
                  ramp-capacity-2 = "";
                  ramp-capacity-3 = "";
                  ramp-capacity-4 = "";
                  ramp-capacity-5 = "";

                  time-format = "%H:%M";
                  poll-interval = 2;
                  inherit (config.desktop.battery) full-at low-at battery adapter;
                };
                "module/backlight" = {
                  type = "internal/backlight";
                  inherit (config.desktop.backlight) card;
                  enable-scroll = true;
                  format = "%{T2}<ramp>%{T-} <label>";
                  label = "%percentage%%";
                  ramp-0 = "";
                  ramp-1 = "";
                  ramp-2 = "";
                  ramp-3 = "";
                  ramp-4 = "";
                  ramp-5 = "";
                  ramp-6 = "";
                };
                "module/wifi" = {
                  type = "internal/network";
                  interface-type = "wireless";
                  click-left = "";
                  format-connected = "<ramp-signal> <label-connected>";
                  label-connected    = editConnectionsOnClick "%essid%";
                  label-disconnected = editConnectionsOnClick " Déconnecté";
                  ramp-signal-0 = "";
                  ramp-signal-1 = "";
                  ramp-signal-2 = "";
                  ramp-signal-3 = "";
                  ramp-signal-4 = "";
                };
              }
            );
          script = "polybar main &";
        };

        picom = {
          enable = true;
          activeOpacity = 0.95;

          settings = {
            # blur is now configured here
          };
          # blur = false;

          inactiveOpacity = 0.93;
          menuOpacity = 0.95;
          opacityRules = [ "100:name *= 'i3lock'" "100:class_g *= 'firefox'" "100:class_g *= 'Zeal'"];
          vSync = false;
        };

        random-background = {
          enable = true;
          imageDirectory = backgrounds.outPath;
          interval = "20 minutes";
        };

        redshift = lib.mkIf (! (config.desktop.virtual-machine)) {
          enable = true;
          settings = {
            redshift = {
              brightness-day = "1";
              brightness-night = "0.5";
            };
          };
          tray = true;
          inherit (config.desktop.location) latitude longitude;
        };

        screen-locker = lib.mkIf (! (config.desktop.virtual-machine)) {
          enable = true;
          inactiveInterval = 120;
          inherit lockCmd;
        };
      };

      xsession.windowManager.i3 =
        let mkWorkspace = index: name: { inherit index name; };

            terminal      = mkWorkspace 1 "Terminal";
            web           = mkWorkspace 2 "Web";
            pro           = mkWorkspace 3 "Pro";
            chat          = mkWorkspace 4 "Chat";
            files         = mkWorkspace 5 "Files";
            documentation = mkWorkspace 6 "Documentation";
            capture       = mkWorkspace 9 "Capture";
        in {
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
                  mkBind = key: command: {
                    "${modifier}+${key}" = "exec ${command}";
                  };
                  mkBindRelease = key: command: {
                    "--release ${modifier}+${key}" = "exec ${command}";
                  };
                  bindings = mkBind        "comma" lockCmd
                          // mkBindRelease "x"     screenshotCmd
                          // bindWorkspaces workspaces;
               in lib.mkOptionDefault bindings;

            menu = "${pkgs.bemenu}/bin/bemenu-run -l 20 -p '>' -i --fn '${font}' -H 15 --hf '${config.desktop.mainColor}' --tf '${config.desktop.mainColor}'";

            startup =
              let onStart = command: { inherit command; always = true; notification = false; };
               in builtins.map onStart [
                    "systemctl --user restart polybar.service"
                  ];

            assigns =
              let assignToWorkspace = {index, name} : assignments: { "${builtins.toString index}: ${name}" = assignments; };
               in concat
                    [ (assignToWorkspace files         [ { class = "^org.gnome.Nautilus$"; } ])
                      (assignToWorkspace capture       [ { class = "^.shutter-wrapped$";   } ])
                      (assignToWorkspace documentation [ { class = "^Zeal$";               } ])
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
