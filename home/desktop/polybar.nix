{ config, lib, pkgs, ... }:

let bottom = true;

    palette = import ../palette.nix;

    baseSize = config.desktop.fontSize;

    inherit (import ../fonts.nix { inherit baseSize; }) roboto toPolybar;

    toggle-redshift = pkgs.callPackage ./toggle-redshift.nix {};

    focus-by-classname = pkgs.callPackage ./focus-by-classname {};

    focus = class-pattern: command: "${focus-by-classname}/bin/focus-by-classname ${class-pattern} ${command}";

    toggleRedshiftOnClick  = onClick "${toggle-redshift}/bin/toggle-redshift";
    editConnectionsOnClick = onClick "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
    monitorOnClick         = onClick (focus "^Com.github.stsdc.monitor$" "${pkgs.monitor}/bin/com.github.stsdc.monitor");

    browse = pkgs.callPackage ./browse { profile = "${config.home.homeDirectory}/.nix-profile"; };
    browseOnClick = url: onClick "${browse}/bin/browse ${builtins.replaceStrings [":"] ["\\\\:"] url}";

    onClick = program: label:
      "%{A1:${program}:}${label}%{A}";

    materialSymbolsOutlinedPolybar = "Material Symbols Outlined:size=${toString baseSize};${if baseSize <= 10 then "3" else "4"}";
    fontAwesomePolybar = "FontAwesome6Brands:size=${toString baseSize};${if baseSize <= 10 then "2" else "3"}";

    isPhysicalHost = ! config.desktop.virtual-machine;
    hasGithub = builtins.isString config.desktop.github.token;

    modules-right =
      let inherit (lib.strings) optionalString;

          github = optionalString hasGithub "github";

          physicalHost = optionalString isPhysicalHost "wifi audio backlight battery";
       in "${github} cpu memory storage ${physicalHost} date";
in
{
  options = with lib; {
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

    desktop.github.username = mkOption {
      type = types.str;
    };
    desktop.github.token = mkOption {
      type = types.nullOr types.str;
      description = "Path to a file containing your Github API token. See https://github.com/settings/tokens/new?scopes=notifications&description=Notifier+for+Polybar.";
      default = null;
    };
  };

  config = {
    desktop.exec-on-login = [
      "systemctl --user restart polybar.service"
    ];

    services.polybar = {
      enable = true;
      package = pkgs.polybarFull;
      settings = {
        "bar/main" = {
          font-0 = toPolybar roboto + ";2";
          font-1 = materialSymbolsOutlinedPolybar;
          font-2 = fontAwesomePolybar;
          inherit bottom;
          height = "${toString (builtins.ceil (baseSize * 2.2))}pt";
          radius = 6;
          width = "100%";
          modules-left = "i3";
          inherit modules-right;
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

          cursor.click  = "pointer";
          cursor.scroll = "ns-resize";
        };

        "settings" = {
          screenschange-reload = true;
        };

        "module/cpu" = let label = "%{T2}%{T-} %percentage%%"; in {
          type = "internal/cpu";
          interval = "0.5";
          warn-percentage = 95;
          format = monitorOnClick "<label>";
          inherit label;
          label-warn = {
            text = label;
            foreground = config.desktop.warnColor;
          };
        };

        "module/memory" = {
          type = "internal/memory";
          interval = "0.5";
          format = monitorOnClick "<label>";
          label = "%{T2}%{T-} %free%";
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

          label-focused = {
            text = "%name%";
            foreground = "#ffffff";
            background = "#3f3f3f";
            underline = config.desktop.mainColor; # "#fba922";
            inherit padding;
          };

          label-unfocused = {
            text = "%name%";
            inherit padding;
          };

          label-urgent = {
            text = "%name% [%index%]";
            foreground = palette.vivid.white;
            background = palette.mate.cyan;
            inherit padding;
          };

          label-separator = {
            text = "|";
            foreground = config.desktop.mainColor;
            padding = 1;
          };

          wrapping-scroll = false;
        };

        "module/date" = {
          type = "internal/date";
          date = "%Y-%m-%d";
          time = "%H:%M";
          label = "%{T2}%{T-}  %date%  %time%";
        };
      } // lib.optionalAttrs hasGithub {
        "module/github" = {
          type = "internal/github";

          user = config.desktop.github.username;
          token = "\${file:${config.desktop.github.token}}";

          empty-notifications = false;
          interval = 10;

          label = browseOnClick "https://github.com/notifications" "%{T3}%{T-}  %notifications%";

          label-offline = {
            text = "%{T3}%{T-}  hors ligne";
            foreground = config.desktop.disabledColor;
          };
        };
      } // lib.optionalAttrs isPhysicalHost {
        "module/battery" = let defaultLabel = "%time%"; in {
          type = "internal/battery";

          format-charging = "<animation-charging> <label-charging>";
          # So sad we can't have ramps specifics for charging and discharging
          animation-charging = {
            text       = [ "" "" "" "" "" "" "" ];
            font       = 2;
            framerate  = 750;
            foreground = config.desktop.activeColor;
          };
          label-charging = defaultLabel;

          format-discharging = "<ramp-capacity> <label-discharging>";
          ramp-capacity = {
            text = [ "" "" "" "" "" "" "" ];
            font = 2;
          };
          label-discharging = defaultLabel;

          format-full = {
            text       = "<ramp-capacity> <label-full>";
            foreground = config.desktop.activeColor;
          };
          label-full = "chargée";

          format-low = {
            text       = "<animation-low> <label-low>";
            foreground = config.desktop.warnColor;
          };

          animation-low = {
            text      = [ "" " " ];
            font      = 2;
            framerate = 1000;
          };
          label-low = defaultLabel;

          time-format = "%H:%M";
          poll-interval = 1;
          inherit (config.desktop.battery) full-at low-at battery adapter;
        };

        "module/backlight" = {
          type = "internal/backlight";
          inherit (config.desktop.backlight) card;
          enable-scroll = true;

          format = toggleRedshiftOnClick "<ramp> <label>";
          label = "%percentage%%";
          ramp = {
            text = [ "" "" "" "" "" "" "" ];
            font = 2;
          };
        };

        "module/wifi" = {
          type = "internal/network";
          interface-type = "wireless";

          format-connected = "<ramp-signal> <label-connected>";
          label-connected = editConnectionsOnClick "%essid%";
          ramp-signal = {
            text = [ "" "" "" "" "" ];
            font = 2;
          };

          label-disconnected = {
            text       = editConnectionsOnClick "%{T2}%{T-} déconnecté";
            foreground = config.desktop.disabledColor;
          };
        };

        "module/audio" = {
          type = "internal/pulseaudio";

          format-volume = "<ramp-volume> <label-volume>";

          ramp-volume = {
            text = [ "" "" "" ];
            font = 2;
          };

          label-muted = {
            text = "%{T2}%{T-} sourdine";
            foreground = config.desktop.disabledColor;
          };
        };
      };
      script = "polybar main &";
    };
  };
}
