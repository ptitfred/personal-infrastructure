{ config, lib, pkgs, ... }:

let isPhysicalHost = ! config.desktop.virtual-machine;
in
{
  config = lib.mkIf (isPhysicalHost && config.desktop.windowManager == "hyprland") {
    services.hypridle.enable = true;
    services.hypridle.settings = {
      general = {
        ignore_dbus_inhibit = false;
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || hyprlock";
        unlock_cmd = "${pkgs.procps}/bin/pkill -USR1 hyprlock";

        after_sleep_cmd = "hyprctl dispatch dmps on";
      };

      listener =
        let after = timeout: props: props // { inherit timeout; };
            dimScreen = {
                on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl --save set 10%";
                on-resume  = "${pkgs.brightnessctl}/bin/brightnessctl --restore";
              };
            dimKeyboard = lib.optionalAttrs (config.desktop.keyboardDevice != null) {
              on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl --device=${config.desktop.keyboardDevice} --save set 0";
              # --restore doesn't work for this device for some reason
              on-resume  = "${pkgs.brightnessctl}/bin/brightnessctl --device=${config.desktop.keyboardDevice} --save set 60";
            };
            lockScreen = {
              on-timeout = "loginctl lock-session";
            };
            turnOffScreen = {
              on-timeout = "hyprctl dispatch dpms off";
              on-resume  = "hyprctl dispatch dpms on";
            };
         in [
              (after 300 dimScreen)
              (after 300 dimKeyboard)
              (after 600 lockScreen)
              (after 900 turnOffScreen)
            ];
    };
  };
}
