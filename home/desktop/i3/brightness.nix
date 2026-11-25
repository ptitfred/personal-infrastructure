{ config, pkgs, lib, ... }:

{
  options.desktop.brightness-step = lib.mkOption {
    type = lib.types.int;
    default = 5;
  };

  config = lib.mkIf (! config.desktop.virtual-machine && config.desktop.windowManager == "i3") {
    desktop.i3-extra-bindings = {
      "XF86MonBrightnessUp"   = "${pkgs.brightnessctl}/bin/brightnessctl s ${toString config.desktop.brightness-step}%+";
      "XF86MonBrightnessDown" = "${pkgs.brightnessctl}/bin/brightnessctl s ${toString config.desktop.brightness-step}%-";
    };
  };
}
