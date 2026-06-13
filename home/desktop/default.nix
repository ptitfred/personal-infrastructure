{ config, lib, pkgs, ... }:

{
  imports = [
    ./firefox.nix
    ./fonts.nix
    ./hyprland
    ./i3
    ./theme.nix
  ];

  options = with lib; {
    desktop.windowManager = mkOption {
      type = types.str;
    };

    desktop.virtual-machine = mkOption {
      type = types.bool;
      default = false;
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

    desktop.github.username = mkOption {
      type = types.str;
    };

    desktop.github.token = mkOption {
      type = types.nullOr types.str;
      description = "Path to a file containing your Github API token. See https://github.com/settings/tokens/new?scopes=notifications&description=Notifier+for+Polybar.";
      default = null;
    };

    desktop.spacing = mkOption {
      type = types.int;
      description = "";
      default = 10;
    };

    desktop.keyboardDevice = mkOption {
      type = types.nullOr types.str;
      description = "Device name of a keyboard (on laptops) to dim it automatically. Use `brightnessctl -l`.";
      example = "framework_laptop::kbd_backlight";
    };
  };

  config = {
    home.packages =
      [ pkgs.nautilus ] ++ (lib.optionals (!config.desktop.virtual-machine) [ pkgs.networkmanager ]);
  };
}
