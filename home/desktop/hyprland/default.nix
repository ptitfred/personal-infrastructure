{ config, lib, pkgs, ... }:

let assets = import ../../assets { baseSize = config.desktop.fontSize; };
    inherit (assets.fonts) roboto toGTK;
    font = toGTK roboto;

    menu = pkgs.writeShellScript "bemenu" ''
      ${pkgs.bemenu}/bin/bemenu-run -l 20 -p '>' -i --fn '${font}' -H 15 --hf '${config.desktop.mainColor}' --tf '${config.desktop.mainColor}'
    '';

    forward_compatibility =
      if pkgs.hyprlock.version == "0.5.0"
      then backport_to_0_5_0
      else pkgs.lib.trivial.id;

    backport_to_0_5_0 = attrs:
      let inherit (lib.attrsets) attrByPath filterAttrs removeAttrs;
          cleaned = removeAttrs attrs ["auth"];
          dropNulls = filterAttrs (_: v: ! (builtins.isNull v));
          complement = {
            general = dropNulls {
              pam_module = attrByPath [ "auth" "pam" "module" ] null attrs;
              enable_fingerprint = attrByPath [ "auth" "fingerprint" "enabled" ] null attrs;
              fingerprint_ready_message = attrByPath [ "auth" "fingerprint" "ready_message" ] null attrs;
              fingerprint_present_message = attrByPath [ "auth" "fingerprint" "present_message" ] null attrs;
            };
          };
      in cleaned // complement;

    hexa_to_rgb =
      let inherit (lib.strings) hasPrefix removePrefix;
       in c:
            if hasPrefix "#" c
            then "rgb(${removePrefix "#" c})"
            else c;

    mixer = command: "${pkgs.alsa-utils}/bin/amixer set Master ${command}";

    count-github-notifications = githubTokenFile:
      pkgs.count-github-notifications.override { inherit githubTokenFile; };

    browse = pkgs.callPackage ../browse { profile = "${config.home.homeDirectory}/.nix-profile"; };
    browseOnClick = url: "${browse}/bin/browse ${url}";

    allMonitors = [ "eDP-1" ] ++ externalMonitors;
    externalMonitors = [ "DP-1" "DP-2" "DP-3" "DP-4" ];

    isPhysicalHost = ! config.desktop.virtual-machine;
    hasGithub = builtins.isString config.desktop.github.token;
in
{
  config = lib.mkIf (config.desktop.windowManager == "hyprland") {
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 28;
      # hyprcursor.enable = true;
    };

    gtk.enable = true;

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
    };

    wayland.windowManager.hyprland.enable = true; # enable Hyprland

    # Optional, hint Electron apps to use Wayland:
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.waybar.enable = true;
    programs.waybar.settings =
      let physicalHostModules = [ "network" "pulseaudio" "backlight" "battery" ];
          githubModules = [ "custom/github" ];
          workspaces = {
                sort-by-number = true;

                format = "{icon}";
                format-icons = {
                  "1" = "Terminal";
                  "2" = "Web";
                  "3" = "Pro";
                  "4" = "Chat";
                  "5" = "Files";
                  "6" = "Documentation";
                  "7" = "Projection";
                  "8" = "Système";
                  "9" = "Capture";
                };

                on-click = "activate";

                disable-scroll = false;
                on-scroll-up = "hyprctl dispatch workspace e-1";
                on-scroll-down = "hyprctl dispatch workspace e+1";
              };
       in {
            mainBar = {
              layer = "top";
              position = "bottom";
              margin-top = 0;
              margin-left = config.desktop.spacing;
              margin-bottom = config.desktop.spacing;
              margin-right = config.desktop.spacing;

              output = [
                "eDP-1"
              ];

              modules-left = [ "hyprland/workspaces" ];
              modules-center = [];
              modules-right = lib.lists.flatten [ githubModules "cpu" "memory" "disk" physicalHostModules "clock" "custom/power" ];

              "hyprland/workspaces" = workspaces;

              "cpu" = {
                interval = 1;
                format = "  {usage}%";
                tooltip = false;
              };

              "disk" = {
                interval = 30;
                path = "/";
                format = "  / {free}";
                tooltip = false;
              };

              "memory" = {
                interval = 1;
                format = "  {avail}Go";
                tooltip = false;
              };

              "clock" = {
                format = "  {:%Y-%m-%d %H:%M}";
                tooltip = false;
              };

              "custom/power" = {
                format = "⏻ ";
                tooltip = false;
                menu = "on-click";
                menu-file = ./power-menu.xml;
                menu-actions = {
                  shutdown = "shutdown";
                  reboot = "reboot";
                  suspend = "systemctl suspend";
                };
              };
            } // lib.optionalAttrs hasGithub {
              "custom/github" = {
                return-type = "json";
                format = "  {}";
                interval = 60;
                exec = "${count-github-notifications config.desktop.github.token}/bin/count-github-notifications";
                on-click = browseOnClick "https://github.com/notifications";
              };
            } // lib.optionalAttrs isPhysicalHost {
              "network" = {
                format-wifi = "{icon}  {essid}";
                format-ethernet = "  {ipaddr}/{cidr}";
                format-linked = "  {ifname} (No IP)";
                format-disconnected = "⚠ déconnecté";
                format-icons = {
                  wifi = [ "" "" "" "" "" ];
                };
                on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
                tooltip = false;
              };

              "backlight" = {
                format = "{icon} {percent}%";
                format-icons = [ "" "" "" "" "" "" "" ];
                device = config.desktop.backlight.card;
                tooltip = false;
              };

              "battery" = {
                inherit (config.desktop.battery) adapter full-at;
                bat = config.desktop.battery.battery;

                interval = 15;

                format = "{icon}  {time}";
                format-icons = {
                  # TODO charging icons from material-symbols
                  charging = [ "" ];
                  # charging = [" " "" " " " " " " " " " " " " ];
                  default = [ "" "" "" "" "" "" "" ];
                };

                format-time = "{H}:{m}";

                states = {
                  warning = 15;
                  critical = 8;
                };

                tooltip = false;
              };

              "pulseaudio" = {
                format = "{icon} {volume}%";
                format-icons = {
                  headphone = "";
                  hands-free = "";
                  headset = "";
                  phone = "";
                  phone-muted = "";
                  portable = "";
                  car = "";
                  default = ["" ""];
                };

                format-muted = " sourdine";

                tooltip = false;

                on-click = mixer "toggle";
              };

            };

            otherBar =
              let monitors = externalMonitors;
               in {
                    layer = "top";
                    position = "bottom";
                    margin-top    = 0;
                    margin-left   = config.desktop.spacing;
                    margin-bottom = config.desktop.spacing;
                    margin-right  = config.desktop.spacing;

                    output = monitors;

                    modules-left   = [ "hyprland/workspaces" ];
                    modules-center = [];
                    modules-right  = [];

                    "hyprland/workspaces" = workspaces // {
                      persistent-workspaces = {
                        "7" = monitors;
                      };
                    };
                  };
          };
    programs.waybar.style = ''
      @define-color activeColor   ${config.desktop.activeColor};
      @define-color disabledColor ${config.desktop.disabledColor};
      @define-color mainColor     ${config.desktop.mainColor};
      @define-color warnColor     ${config.desktop.warnColor};
      * {
        font-family: ${roboto.name};
        font-size: ${toString (roboto.size + 2)}px;
      }
      ${builtins.readFile ./waybar-style.css}
    '';

    # Focus the workspace with the last focused window of a given class
    # hyprctl -j clients | jq -r '. | sort_by(.focusHistoryID) | .[] | select(.class == "firefox") | .workspace.id' | head -1

    wayland.windowManager.hyprland.settings = {
      monitor =
        [
          ",preferred,auto,1.175"
          "DP-3,preferred,auto,1.2"
        ];

      "$terminal" = "kitty";
      "$fileManager" = "nautilus";

      env =
        [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

      # Refer to https://wiki.hyprland.org/Configuring/Variables/

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general = {
        gaps_in = config.desktop.spacing / 2;
        gaps_out = config.desktop.spacing;

        border_size = 1;

        # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
        "col.active_border" = hexa_to_rgb config.desktop.mainColor; # "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        # Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true;

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;

        layout = "dwindle";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration = {
        rounding = 1;

        # Change transparency of focused and unfocused windows
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        # https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };

        # screen_shader = "${./grayscale.frag}";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations = {
        enabled = true; # "yes, please :)";

        # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier =
          [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];

        animation =
          [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
      };

      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      dwindle = {
        pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # You probably want this
      };

      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      master = {
        new_status = "master";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc = {
        force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
      };

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input = {
        kb_layout = "fr";
        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        touchpad = {
          natural_scroll = false;
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gesture = [
        "3, horizontal, workspace"
        "3, up, fullscreen"
        "3, down, fullscreen, minimize"
        "4, down, dispatcher, exec, hyprlock --immediate"
      ];

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      binds = {
        workspace_back_and_forth = true;
      };

      # See https://wiki.hyprland.org/Configuring/Keywords/
      "$mainMod" = "SUPER"; # Sets "Windows" key as main modifier

      bind =
        [
          # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          "$mainMod, return, exec, $terminal"
          "$mainMod, C, killactive,"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"
          "$mainMod, D, exec, ${menu}"
          "$mainMod, P, pseudo," # dwindle
          "$mainMod, J, togglesplit," # dwindle
          "$mainMod, F, fullscreen"
          "$mainMod, comma, exec, loginctl lock-session"

          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Switch workspaces with mainMod + [0-9] on a French layout
          "$mainMod, ampersand, workspace, 1"
          "$mainMod, eacute, workspace, 2"
          "$mainMod, quotedbl, workspace, 3"
          "$mainMod, apostrophe, workspace, 4"
          "$mainMod, parenleft, workspace, 5"
          "$mainMod, minus, workspace, 6"
          "$mainMod, egrave, workspace, 7"
          "$mainMod, underscore, workspace, 8"
          "$mainMod, ccedilla, workspace, 9"
          "$mainMod, agrave, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9] on a French layout
          "$mainMod SHIFT, ampersand, movetoworkspacesilent, 1"
          "$mainMod SHIFT, eacute, movetoworkspacesilent, 2"
          "$mainMod SHIFT, quotedbl, movetoworkspacesilent, 3"
          "$mainMod SHIFT, apostrophe, movetoworkspacesilent, 4"
          "$mainMod SHIFT, parenleft, movetoworkspacesilent, 5"
          "$mainMod SHIFT, minus, movetoworkspacesilent, 6"
          "$mainMod SHIFT, egrave, movetoworkspacesilent, 7"
          "$mainMod SHIFT, underscore, movetoworkspacesilent, 8"
          "$mainMod SHIFT, ccedilla, movetoworkspacesilent, 9"
          "$mainMod SHIFT, agrave, movetoworkspacesilent, 10"

          # Example special workspace (scratchpad)
          "$mainMod, Q, togglespecialworkspace, magic"
          "$mainMod SHIFT, Q, movetoworkspacesilent, special:magic"

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          "$mainMod, S, togglegroup"
        ];

      bindm =
        [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

      bindel =
        [
          # Laptop multimedia keys for volume and LCD brightness
          ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 10%+"
          ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 10%-"
        ];

      bindl =
        [
          # Requires playerctl
          ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
          ", XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"

          # Lock on lid open
          ",switch:on:Lid Switch, exec, hyprlock --immediate"
          # Lock lid on close
          ",switch:off:Lid Switch, exec, hyprlock --immediate"
        ];

      exec-once =
        [
          "waybar"
          "wpaperd -d"
        ];

      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################

      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

      windowrule =
        [
          "opacity 0.92 0.88 0.92,class:^(kitty)$"
          "bordersize 0,class:^(firefox)$"
          "workspace 6 silent,class:^(org.zealdocs.zeal)$"

          "float,class:^(nm-connection-editor)$"
          "center 1,class:^(nm-connection-editor)$"

          # Ignore maximize requests from apps. You'll probably like this.
          "suppressevent maximize, class:.*"

          # Fix some dragging issues with XWayland
          "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        ];

      workspace = [
        "7, monitor:DP-3"
      ];
    };

    programs.hyprlock.enable = true;
    programs.hyprlock.settings = forward_compatibility  {
      general = {
        # disable_loading_bar = true;
        grace = 10;
        # hide_cursor = false;
        # no_fade_in = false;
      };
      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "200, 50";
          outline_thickness = 3;
          inner_color = "rgba(0, 0, 0, 0.0)"; # no fill

          dots_size = 0.2;
          dots_spacing = 0.35;

          outer_color = "rgba(33ccffee)";
          check_color = "rgba(00ff99ee)";
          fail_color = "rgba(ff6633ee)";

          # font_family = roboto.name;
          font_color = "rgb(30, 30, 30)";
          fade_on_empty = false;
          rounding = 15;

          hide_input = false;
          position = "0, -20";
          halign = "center";
          valign = "center";

          placeholder_text = "<span foreground=\"##666666\">Password…</span>";
          # shadow_passes = 2;
        }
      ];

      auth = {
        pam = {
          enabled = true;
        };
        fingerprint = {
          enabled = true;
          ready_message = "Place your right index finger on the detector";
          present_message = "Scanning the dirt...";
        };
      };

      label = [
        # time
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%H:%M\")\"";
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 95;
          font_family = roboto.name;
          position = "0, 200";
          halign = "center";
          valign = "center";
        }

        # user
        {
          monitor = "";
          text = "$DESC";
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 32;
          font_family = roboto.name;
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };

    services.hypridle.enable = true;
    services.hypridle.settings = {
      general = {
        ignore_dbus_inhibit = false;
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || hyprlock";
        unlock_cmd = "${pkgs.procps}/bin/pkill -USR1 hyprlock";

        after_sleep_cmd = "hyprctl dispatch dmps on";
      };

      listener =
        let after = timeout: props: props // { inherit timeout; };
            dimScreen = {
                on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl --save set 10%";
                on-resume  = "${pkgs.brightnessctl}/bin/brightnessctl --restore";
              };
            dimKeyboard = lib.optionalAttrs (config.desktop.keyboardDevice != null) {
              on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl --device=${config.desktop.keyboardDevice} --save set 0";
              # --restore doesn't work for this device for some reason
              on-resume  = "${pkgs.brightnessctl}/bin/brightnessctl --device=${config.desktop.keyboardDevice} --save set 60";
            };
            lockScreen = {
              on-timeout = "loginctl lock-session";
            };
            turnOffScreen = {
              on-timeout = "hyprctl dispatch dpms off";
              on-resume  = "hyprctl dispatch dpms on";
            };
         in [
              (after 300 dimScreen)
              (after 300 dimKeyboard)
              (after 600 lockScreen)
              (after 900 turnOffScreen)
            ];
    };

    services.wpaperd.enable = true;
    services.wpaperd.settings = lib.attrsets.genAttrs allMonitors (_:
      {
        path = pkgs.backgrounds.outPath;
        duration = "15m";
        mode = "center";
      });

    services.mako.enable = true;
    services.mako.settings.output = "eDP-1";
  };
}
