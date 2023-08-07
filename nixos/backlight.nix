{ config, lib, ... }:

let cfg = config.backlight-support;
 in
{
  options.backlight-support = {
    enable = lib.mkEnableOption "should this host support backlight";
    user = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf (cfg.enable){
    programs.light.enable = true;
    users.users.${cfg.user}.extraGroups = [ "video" ];
  };
}
