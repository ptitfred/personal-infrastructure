{ config, lib, pkgs, ... }:

let lockCmd = "${pkgs.lightdm}/bin/dm-tool lock";

    binding = "${modifier}+${key}";
    modifier = config.xsession.windowManager.i3.config.modifier;
    key = config.desktop.locker-key;
in
{
  options = {
    desktop.locker-key = lib.mkOption {
      type = lib.types.str;
      default = "comma";
    };
    desktop.locker-interval = lib.mkOption {
      type = lib.types.int;
      default = 10;
    };
  };

  config = {
    services.screen-locker = lib.mkIf (config.desktop.windowManager == "i3" && ! (config.desktop.virtual-machine)) {
      enable = lib.mkDefault false;
      inactiveInterval = config.desktop.locker-interval;
      inherit lockCmd;
    };

    desktop.i3-extra-bindings = lib.mkIf (config.desktop.windowManager == "i3") { ${binding} = "exec ${lockCmd}"; };

    # This is required to make xss-lock work
    xsession.enable = config.desktop.windowManager == "i3";
    xsession.importedVariables = lib.mkIf (config.desktop.windowManager == "i3") [ "XDG_SEAT" "XDG_SEAT_PATH" ];
  };
}
