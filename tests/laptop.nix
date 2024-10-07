{ ... }:

{
  desktop = {
    virtual-machine = false;
    mainColor = "#FF0000";
    location = { latitude = "44.0003"; longitude = "4.20001"; };
    spacing = 10;
    battery = {
      adapter = "ADC0";
      battery = "BAT0";
    };
  };

  home.username = "test";
  home.homeDirectory = "/home/test";
}
