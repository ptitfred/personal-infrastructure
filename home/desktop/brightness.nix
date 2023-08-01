{ config, pkgs, lib, ... }:

let changeBrightness = variant: "exec --no-startup-id ${pkgs.light}/bin/light ${variant} ${toString config.desktop.brightness-step}";

 in
{
  options.desktop.brightness-step = lib.mkOption {
    type = lib.types.int;
    default = 5;
  };

  config = lib.mkIf (! config.desktop.virtual-machine) {
    desktop.i3-extra-bindings = {
      "XF86MonBrightnessUp"   = changeBrightness "-A";
      "XF86MonBrightnessDown" = changeBrightness "-U";
    };
  };
}
