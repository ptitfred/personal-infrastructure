{ config, lib, pkgs, ... }:

{
  imports = [
    ./firefox.nix
    ./notifications.nix
    ./brightness.nix
    ./audio.nix
    ./wifi.nix
    ./polybar.nix
    ./screenlocker.nix
    ./redshift.nix
    ./random-background.nix
    ./picom.nix
    ./i3.nix
    ./fonts.nix
    ./theme.nix
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
