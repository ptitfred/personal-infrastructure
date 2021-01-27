{ config, lib, pkgs, ... }:

let regionParisienne =
      {
        latitude = "48.89";
        longitude = "2.24";
      };
    orange = "#ffb52a";
    lockCmd = "${pkgs.posix-toolbox.i3-screen-locker}/bin/i3-screen-locker";
    spacing = 10;
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
          "bar/top" = {
            font-0 = "Roboto:size=9;2";
            bottom = false;
            # height = 20;
            radius = 4;
            width = "100%";
            modules-left = "i3";
            modules-right = "memory date";
            background = "#99000000";
            padding = 3;
            border-size = spacing;
            border-bottom-size = 0;
            separator = "|";
            module-margin = 2;
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
        script = "polybar top &";
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
      config = {
        bars = []; # we rely on polybar
        colors = {
          focused = lib.mkOptionDefault {
            border      = lib.mkForce orange;
            childBorder = lib.mkForce orange;
            indicator   = lib.mkForce orange;
          };
        };
        gaps.inner = spacing;
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
        menu = "${pkgs.bemenu}/bin/bemenu-run -l 20 -p '>' -i --fn 'Roboto 9' -H 15 --hf '${orange}' --tf '${orange}'";
        startup = [
          { command = "systemctl --user restart polybar"; always = true; notification = false; }
        ];
        workspaceAutoBackAndForth = true;
      };
    };

    xresources.properties = {
      # Colorscheme (for urxvt), from https://addy-dclxvi.github.io/post/configuring-urxvt/

      # special
      "*.foreground" = "#93a1a1";
      "*.background" = "#141c21";
      "*.cursorColor" = "#afbfbf";

      # black
      "*.color0" = "#263640";
      "*.color8" = "#4a697d";

      # red
      "*.color1" = "#d12f2c";
      "*.color9" = "#fa3935";

      # green
      "*.color2" = "#819400";
      "*.color10" = "#a4bd00";

      # yellow
      "*.color3" = "#b08500";
      "*.color11" = "#d9a400";

      # blue
      "*.color4" = "#2587cc";
      "*.color12" = "#2ca2f5";

      # magenta
      "*.color5" = "#696ebf";
      "*.color13" = "#8086e8";

      # cyan
      "*.color6" = "#289c93";
      "*.color14" = "#33c5ba";

      # white
      "*.color7" = "#bfbaac";
      "*.color15" = "#fdf6e3";
    };

  }
