{ config, lib, pkgs, ... }:

let locker = pkgs.callPackage ./locker.nix {};
    lockCmd = "${locker}/bin/locker";

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
    services.screen-locker = lib.mkIf (! (config.desktop.virtual-machine)) {
      enable = true;
      inactiveInterval = config.desktop.locker-interval;
      inherit lockCmd;
    };

    desktop.i3-extra-bindings.${binding} = "exec ${lockCmd}";
  };
}
