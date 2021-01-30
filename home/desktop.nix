{ config, lib, pkgs, ... }:

let regionParisienne =
      {
        latitude = "48.89";
        longitude = "2.24";
      };
    orange = "#ffb52a";
    lockCmd = "${pkgs.posix-toolbox.i3-screen-locker}/bin/i3-screen-locker";
    spacing = 10;
    bottom = true;

    palette = import ./palette.nix;

    fonts = import ./fonts.nix;
    inherit (fonts) roboto toPolybar toI3 toGTK;
in
  {
    home.packages = [
      pkgs.networkmanager
      pkgs.networkmanagerapplet
      pkgs.gnome3.nautilus
    ];

    programs = {

      firefox = {
        enable = true;
        profiles = {
          perso = {
            id = 0;
            settings = {
              "intl.accept_languages" = "fr, fr-FR, en-US, en";
              "intl.locale.requested" = "fr, en-US";
              "services.sync.username" = "frederic.menou@gmail.com";
            };
          };
        };
      };

    };

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
            gtk-application-prefer-dark-theme = 0;
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
        package = pkgs.polybar.override {
          i3 = true;
          i3GapsSupport = true;
        };
        config = {
          "bar/main" = {
            font-0 = toPolybar roboto + ";2";
            inherit bottom;
            # height = 20;
            radius = 4;
            width = "100%";
            modules-left = "i3";
            modules-right = "memory date";
            background = "#99000000";
            padding = 3;
            border-size = spacing;
            border-top-size = if bottom then 0 else spacing;
            border-bottom-size = if bottom then spacing else 0;
            separator = "|";
            module-margin = 2;
            locale = "fr_FR.UTF-8";
            tray-position = "center";
          };

          "module/memory" = {
            type = "internal/memory";
            interval = "0.5";
            format = "<label>";
            label = "Mémoire libre  %gb_free%";
          };

          "module/i3" = let padding = 2; in {
            type = "internal/i3";
            strip-wsnumbers = true;
            label-focused = "%name%";
            label-focused-foreground = "#ffffff";
            label-focused-background = "#3f3f3f";
            label-focused-underline = "#fba922";
            label-focused-padding = padding;
            label-unfocused = "%name%";
            label-unfocused-padding = padding;
            label-urgent = "%name% [%index%]";
            label-urgent-foreground = palette.vivid.white;
            label-urgent-background = palette.mate.cyan;
            label-urgent-padding = padding;
            label-separator = "|";
            label-separator-foreground = orange;
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
        };
        script = "polybar main &";
      };

      picom = {
        enable = true;
        activeOpacity = "0.95";
        blur = false;
        inactiveOpacity = "0.93";
        menuOpacity = "0.95";
        opacityRule = [ "100:name *= 'i3lock'" ];
        vSync = false;
      };

      random-background = {
        enable = true;
        imageDirectory = "%h/Pictures/backgrounds";
      };

      redshift = {
        enable = true;
        brightness = {
          day = "1";
          night = "0.5";
        };
        tray = true;
      } // regionParisienne;

      screen-locker = {
        enable = true;
        inactiveInterval = 10;
        inherit lockCmd;
      };
    };

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      config = let font = toI3 roboto; in {
        bars = []; # we rely on polybar
        fonts = [ font ];
        workspaceAutoBackAndForth = true;

        colors = {
          focused = lib.mkOptionDefault {
            border      = lib.mkForce palette.special.background;
            childBorder = lib.mkForce palette.special.background;
            indicator   = lib.mkForce orange;
            background = lib.mkForce palette.special.background;
            text = lib.mkForce orange;
          };
          unfocused = lib.mkOptionDefault {
            text = lib.mkForce palette.mate.white;
          };
        };

        gaps = {
          inner = spacing;
          smartBorders = "on";
        };

        keybindings =
          let modifier = config.xsession.windowManager.i3.config.modifier;
              mkWorkspace = index: name: {
                "${modifier}+${builtins.toString index}"       = "workspace number ${builtins.toString index}:${name}";
                "${modifier}+Shift+${builtins.toString index}" = "move container to workspace number ${builtins.toString index}:${name}";
              };
              mkBind = key: command: {
                "${modifier}+${key}" = "exec ${command}";
              };
              bindings = mkBind "comma" lockCmd
                      // mkWorkspace 1 "Terminal"
                      // mkWorkspace 2 "Chat"
                      // mkWorkspace 3 "Pro"
                      // mkWorkspace 4 "Web"
                      // mkWorkspace 5 "Navigation"
                      // mkWorkspace 9 "Capture";
           in lib.mkOptionDefault bindings;

        menu = "${pkgs.bemenu}/bin/bemenu-run -l 20 -p '>' -i --fn '${font}' -H 15 --hf '${orange}' --tf '${orange}'";

        startup =
          let onStart = command: { inherit command; always = true; notification = false; };
          in
            builtins.map onStart [
              "systemctl --user restart polybar.service"
              "${pkgs.networkmanagerapplet}/bin/nm-applet"
              "${pkgs.shutter}/bin/shutter --min_at_startup"
            ];

        assigns = {
          "5: Navigation" = [ { class = "^org.gnome.Nautilus$"; } ];
          "9: Capture"    = [ { class = "^.shutter-wrapped$"; } ];
        };
      };
      extraConfig = ''
        for_window [class=".*"] title_format "  %title"
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
  }
