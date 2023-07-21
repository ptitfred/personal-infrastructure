{ ... }:

{
  imports = [ ../laptop.nix ];

  desktop = {
    mainColor = "#FF0000";
    location = { latitude = "44.0003"; longitude = "4.20001"; };
    spacing = 10;
  };

  home.username = "test";
  home.homeDirectory = "/home/test";
}
