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

    roboto = { name = "Roboto"; size = "9"; };

    toPolybar = { name, size }: "${name}:size=${size}";
    toI3 = { name, size }: "${name} ${size}";
in
  {
    programs = {

      firefox = {
        enable = true;
        profiles = {
          perso = {
            id = 0;
            settings = {
              "intl.accept_languages" = "fr, fr-FR, en-US, en";
              "intl.locale.requested" = "fr, en-US";
            };
          };
        };
      };

    };

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

          "module/i3" = {
            type = "internal/i3";
            strip-wsnumbers = true;
            label-focused = "%name%";
            label-focused-foreground = "#ffffff";
            label-focused-background = "#3f3f3f";
            label-focused-underline = "#fba922";
            label-focused-padding = 2;
            label-unfocused = "%name%";
            label-unfocused-padding = 2;
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
                      // mkWorkspace 4 "Web";
           in lib.mkOptionDefault bindings;

        menu = "${pkgs.bemenu}/bin/bemenu-run -l 20 -p '>' -i --fn '${font}' -H 15 --hf '${orange}' --tf '${orange}'";

        startup = [
          { command = "systemctl --user restart polybar"; always = true; notification = false; }
        ];
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
