{ config, lib, pkgs, ... }:

{
  services.random-background = lib.mkIf (config.desktop.windowManager == "i3") {
    enable = true;
    imageDirectory = pkgs.backgrounds.outPath;
    interval = "20 minutes";
  };
}
