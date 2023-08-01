{ config, lib, pkgs, ... }:

{
  imports = [
    desktop/firefox.nix
    desktop/notifications.nix
    desktop/brightness.nix
    desktop/audio.nix
    desktop/wifi.nix
    desktop/polybar.nix
    desktop/screenlocker.nix
    desktop/redshift.nix
    desktop/random-background.nix
    desktop/picom.nix
    desktop/i3.nix
    desktop/fonts.nix
    desktop/theme.nix
  ];

  options = with lib; {
    desktop.virtual-machine = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    home.packages =
      if config.desktop.virtual-machine
      then [ pkgs.gnome.nautilus ]
      else [ pkgs.gnome.nautilus pkgs.networkmanager ];
  };
}
