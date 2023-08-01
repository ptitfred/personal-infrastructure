{ pkgs, ... }:

let backgrounds = pkgs.callPackage ./backgrounds {};
in
{
  services.random-background = {
    enable = true;
    imageDirectory = backgrounds.outPath;
    interval = "20 minutes";
  };
}
