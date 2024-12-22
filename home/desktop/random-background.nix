{ pkgs, ... }:

{
  services.random-background = {
    enable = true;
    imageDirectory = pkgs.backgrounds.outPath;
    interval = "20 minutes";
  };
}
