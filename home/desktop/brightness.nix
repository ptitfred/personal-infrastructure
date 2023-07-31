{ config, pkgs, lib, ... }:

{
  options.desktop.brightness-step = lib.mkOption {
    type = lib.types.int;
    default = 5;
  };

  config = lib.mkIf (! config.desktop.virtual-machine) {
    desktop.i3-extra-bindings = {
      "XF86MonBrightnessUp"   = "exec --no-startup-id ${pkgs.light}/bin/light -A ${toString config.desktop.brightness-step}";
      "XF86MonBrightnessDown" = "exec --no-startup-id ${pkgs.light}/bin/light -U ${toString config.desktop.brightness-step}";
    };
  };
}
