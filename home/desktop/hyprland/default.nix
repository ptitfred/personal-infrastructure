{ config, lib, pkgs, ... }:

let assets = import ../../assets { baseSize = config.desktop.fontSize; };
    inherit (assets.fonts) roboto toGTK;
    font = toGTK roboto;

    menu = pkgs.writeShellScript "bemenu" ''
      ${pkgs.bemenu}/bin/bemenu-run -l 20 -p '>' -i --fn '${font}' -H 15 --hf '${config.desktop.mainColor}' --tf '${config.desktop.mainColor}'
    '';

    hexa_to_rgb =
      let inherit (lib.strings) hasPrefix removePrefix;
       in c:
            if hasPrefix "#" c
            then "rgb(${removePrefix "#" c})"
            else c;

    allMonitors = [ output ] ++ externalMonitors;
    inherit (config.desktop) externalMonitors;
    output = config.desktop.mainMonitor;
in
{
  imports = [
    ./idle.nix
    ./screenlocker.nix
    ./terminal.nix
    ./waybar.nix
  ];

  options = {
    desktop.mainMonitor = lib.mkOption {
      type = lib.types.str;
    };

    desktop.externalMonitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf (config.desktop.windowManager == "hyprland") {
    # Focus the workspace with the last focused window of a given class
    # hyprctl -j clients | jq -r '. | sort_by(.focusHistoryID) | .[] | select(.class == "firefox") | .workspace.id' | head -1

    # enable Hyprland
    wayland.windowManager.hyprland.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 28;
      # hyprcursor.enable = true;
    };

    gtk.enable = true;

    # Optional, hint Electron apps to use Wayland:
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    wayland.windowManager.hyprland.configType = "hyprlang";
    wayland.windowManager.hyprland.settings = {
      monitor =
        [
          ",preferred,auto,1.175"
          "DP-3,preferred,auto,1.2"
        ];

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
          "$mainMod, J, layoutmsg, rotatesplit" # dwindle
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
      windowrule = [
        {
          # Terminal's slightly transparent
          name = "rule1";
          opacity = "0.92 0.88 0.92";
          "match:class" = "^(kitty)$";
        }

        {
          # No border for firefox
          name = "rule2";
          border_size = 0;
          "match:class" = "^(firefox)$";
        }

        {
          # Send Zeal to workspace 6
          name = "rule3";
          workspace = "6 silent";
          "match:class" = "^(org.zealdocs.zeal)$";
        }

        {
          # NM connection editor floating
          name = "rule4";
          float = "on";
          center = 1;
          "match:class" = "^(nm-connection-editor)$";
        }

        {
          # Ignore maximize requests from apps. You'll probably like this.
          name = "rule5";
          suppress_event = "maximize";
          "match:class" = ".*";
        }

        {
          # Fix some dragging issues with XWayland
          name = "rule6";
          no_focus = "on";
          "match:class" = "^$";
          "match:title" = "^$";
          "match:xwayland" = true;
          "match:float" = true;
          "match:fullscreen" = false;
          "match:pin" = false;
        }
    ];

      workspace = [
        "7, monitor:DP-3"
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
    services.mako.settings = { inherit output; };
  };
}
