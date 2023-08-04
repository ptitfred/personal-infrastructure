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

    onClick = program: label:
      "%{A1:${program}:}${label}%{A}";

    materialSymbolsOutlinedPolybar = "Material Symbols Outlined:size=${toString baseSize};${if baseSize <= 10 then "3" else "4"}";

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
      config = {
        "bar/main" = {
          font-0 = toPolybar roboto + ";2";
          font-1 = materialSymbolsOutlinedPolybar;
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
          cursor-click  = "pointer";
          cursor-scroll = "ns-resize";
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
          label-warn = label;
          label-warn-foreground = config.desktop.warnColor;
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
      } // lib.optionalAttrs hasGithub {
        "module/github" = {
          type = "internal/github";

          user = config.desktop.github.username;
          token = "\${file:${config.desktop.github.token}}";

          empty-notifications = false;
          interval = 10;

          label = "%{T2}%{T-} %notifications%";
          label-offline = "%{T2}%{T-} hors ligne";
          label-offline-foreground = config.desktop.disabledColor;
        };
      } // lib.optionalAttrs isPhysicalHost {
        "module/battery" = let defaultLabel = "%time%"; in {
          type = "internal/battery";

          format-charging               = "<animation-charging> <label-charging>";
          # So sad we can't have ramps specifics for charging and discharging
          animation-charging-0          = "";
          animation-charging-1          = "";
          animation-charging-2          = "";
          animation-charging-3          = "";
          animation-charging-4          = "";
          animation-charging-5          = "";
          animation-charging-6          = "";
          animation-charging-font       = 2;
          animation-charging-framerate  = 750;
          animation-charging-foreground = config.desktop.activeColor;
          label-charging                = defaultLabel;

          format-discharging = "<ramp-capacity> <label-discharging>";
          ramp-capacity-0    = "";
          ramp-capacity-1    = "";
          ramp-capacity-2    = "";
          ramp-capacity-3    = "";
          ramp-capacity-4    = "";
          ramp-capacity-5    = "";
          ramp-capacity-6    = "";
          ramp-capacity-font = 2;
          label-discharging  = defaultLabel;

          format-full            = "<ramp-capacity> <label-full>";
          format-full-foreground = config.desktop.activeColor;
          label-full             = "chargée";

          format-low               = "<animation-low> <label-low>";
          format-low-foreground    = config.desktop.warnColor;
          animation-low-0          = "";
          animation-low-1          = " ";
          animation-low-font       = 2;
          animation-low-framerate  = 1000;
          label-low                = defaultLabel;

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
          ramp-0 = "";
          ramp-1 = "";
          ramp-2 = "";
          ramp-3 = "";
          ramp-4 = "";
          ramp-5 = "";
          ramp-6 = "";
          ramp-font = 2;
        };

        "module/wifi" = {
          type = "internal/network";
          interface-type = "wireless";
          click-left = "";
          format-connected = "<ramp-signal> <label-connected>";
          label-connected    = editConnectionsOnClick "%essid%";
          label-disconnected = editConnectionsOnClick "%{T2}%{T-} déconnecté";
          label-disconnected-foreground = config.desktop.disabledColor;
          ramp-signal-0 = "";
          ramp-signal-1 = "";
          ramp-signal-2 = "";
          ramp-signal-3 = "";
          ramp-signal-4 = "";
          ramp-signal-font = 2;
        };

        "module/audio" = {
          type = "internal/alsa";

          format-volume = "<ramp-volume> <label-volume>";

          label-muted = "%{T2}%{T-} sourdine";
          label-muted-foreground = config.desktop.disabledColor;

          ramp-volume-0 = "";
          ramp-volume-1 = "";
          ramp-volume-2 = "";
          ramp-volume-font = 2;
        };
      };
      script = "polybar main &";
    };
  };
}
