{ config, lib, pkgs, ... }:

let assets = import ../../assets { baseSize = config.desktop.fontSize; };
    inherit (assets.fonts) roboto toI3 toGTK;

    rofi-screenshot = pkgs.callPackage ./rofi-screenshot {};
    start-rofi-screenshot = "${rofi-screenshot}/bin/rofi-screenshot";
    stop-rofi-screenshot = "${rofi-screenshot}/bin/rofi-screenshot -s";

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
    ./audio.nix
    ./brightness.nix
    ./picom.nix
    ./notifications.nix
    ./polybar.nix
    ./random-background.nix
    ./redshift.nix
    ./screenlocker.nix
    ./wifi.nix
  ];

  options = with lib; {
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
    xsession.windowManager.i3 = lib.mkIf (config.desktop.windowManager == "i3") {
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

          colors = with assets.palette; {
            focused = lib.mkOptionDefault {
              border      = lib.mkForce special.background;
              childBorder = lib.mkForce special.background;
              indicator   = lib.mkForce config.desktop.mainColor;
              background = lib.mkForce special.background;
              text = lib.mkForce config.desktop.mainColor;
            };
            unfocused = lib.mkOptionDefault {
              text = lib.mkForce mate.white;
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
                bindings = mkBindRelease "x"       start-rofi-screenshot
                        // mkBindRelease "Shift+x" stop-rofi-screenshot
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
  };

}
