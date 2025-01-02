{ config, lib, ... }:

{
  services.picom = lib.mkIf (config.desktop.windowManager == "i3") {
    enable = true;
    activeOpacity = 0.95;

    settings = {
      # blur is now configured here
    };
    # blur = false;

    inactiveOpacity = 0.93;
    menuOpacity = 0.95;
    opacityRules = [ "100:class_g *= 'firefox'" "100:class_g *= 'Zeal'"];
    vSync = false;
  };
}
