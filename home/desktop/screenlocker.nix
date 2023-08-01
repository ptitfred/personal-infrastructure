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
  };

  config = {
    services.screen-locker = lib.mkIf (! (config.desktop.virtual-machine)) {
      enable = true;
      inactiveInterval = 120;
      inherit lockCmd;
    };

    desktop.i3-extra-bindings.${binding} = "exec ${lockCmd}";
  };
}
