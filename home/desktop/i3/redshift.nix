{ config, lib, ... }:

{
  options = with lib; {
    desktop.location.latitude = mkOption {
      type = types.str;
      description = ''
        Latitude to use for redshift.
      '';
    };
    desktop.location.longitude = mkOption {
      type = types.str;
      description = ''
        Longitude to use for redshift.
      '';
    };
  };

  config = lib.mkIf (config.desktop.windowManager == "i3") {
    services.redshift = lib.mkIf (! config.desktop.virtual-machine) {
      enable = true;
      settings = {
        redshift = {
          brightness-day = "1";
          brightness-night = "0.5";
        };
      };
      tray = true;
      inherit (config.desktop.location) latitude longitude;
    };
  };
}
