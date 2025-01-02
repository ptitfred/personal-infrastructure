{ config, pkgs, lib, ... }:

let mixer = command: "exec --no-startup-id ${pkgs.alsa-utils}/bin/amixer set Master ${command}";
    step = toString config.desktop.audio-step;
 in
{
  options.desktop.audio-step = lib.mkOption {
    type = lib.types.int;
    default = 5;
  };

  config = lib.mkIf (! config.desktop.virtual-machine && config.desktop.windowManager == "i3") {
    desktop.i3-extra-bindings = {
      "XF86AudioRaiseVolume" = mixer "${step}%+";
      "XF86AudioLowerVolume" = mixer "${step}%-";
      "XF86AudioMute"        = mixer "toggle";
    };
  };
}
