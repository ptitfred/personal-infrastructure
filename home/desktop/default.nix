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
      [ pkgs.gnome.nautilus ] ++ (lib.optionals (!config.desktop.virtual-machine) [ pkgs.networkmanager ]);
  };
}
