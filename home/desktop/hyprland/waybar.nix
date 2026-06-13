{ config, lib, pkgs, ... }:

let assets = import ../../assets { baseSize = config.desktop.fontSize; };
    inherit (assets.fonts) roboto;

    mixer = command: "${pkgs.alsa-utils}/bin/amixer set Master ${command}";

    github-notifications = githubTokenFile:
      pkgs.callPackage ./github-notifications { inherit githubTokenFile; };

    browse = pkgs.callPackage ../browse { profile = "${config.home.homeDirectory}/.nix-profile"; };
    browseOnClick = url: "${browse}/bin/browse ${url}";

    isPhysicalHost = ! config.desktop.virtual-machine;
    hasGithub = builtins.isString config.desktop.github.token;

    inherit (config.desktop) externalMonitors;
    output = config.desktop.mainMonitor;
in
{
  config = lib.mkIf (config.desktop.windowManager == "hyprland") {
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
                output
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
                format = "  {text}";
                interval = 60;
                exec = "${github-notifications config.desktop.github.token}/bin/waybar-github-notifications-module";
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

            otherBar = {
              layer = "top";
              position = "bottom";
              margin-top    = 0;
              margin-left   = config.desktop.spacing;
              margin-bottom = config.desktop.spacing;
              margin-right  = config.desktop.spacing;

              output = externalMonitors;

              modules-left   = [ "hyprland/workspaces" ];
              modules-center = [];
              modules-right  = [];

              "hyprland/workspaces" = workspaces // {
                persistent-workspaces = {
                  "7" = externalMonitors;
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
  };
}
