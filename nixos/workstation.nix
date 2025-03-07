{ config, lib, pkgs, ... }:

let orange = "#ffb52a";
    user = config.workstation.user;

    background = "${pkgs.backgrounds}/pexels-pok-rie-2049422.jpg";
 in
{
  options.workstation.user = lib.mkOption { type = lib.types.str; };

  config = {
    services.xserver.displayManager.gdm = {
      settings = {
        greeter = {
          Include = user;
        };
      };
    };

    services.xserver.displayManager.lightdm = {
      inherit background;

      greeters.mini = {
        enable = false;
        inherit user;
        extraConfig = ''
          [greeter]
          show-password-label = false
          password-alignment = left
          password-input-width = 16
          [greeter-theme]
          window-color = "${orange}"
          border-color = "${orange}"
          layout-space = 2
        '';
      };
    };

    services.fwupd.enable = true;
    services.upower.enable = true;

    nix.settings.substituters = [ "https://cache.garnix.io" ];
    nix.settings.trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
