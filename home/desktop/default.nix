{ config, lib, pkgs, ... }:

{
  imports = [
    ./firefox.nix
    ./fonts.nix
    ./i3
    ./theme.nix
  ];

  options = with lib; {
    desktop.virtual-machine = mkOption {
      type = types.bool;
      default = false;
    };

    desktop.windowManager = mkOption {
      type = types.str;
      default = "i3";
    };
  };

  config = {
    home.packages =
      [ pkgs.nautilus ] ++ (lib.optionals (!config.desktop.virtual-machine) [ pkgs.networkmanager ]);
  };
}
