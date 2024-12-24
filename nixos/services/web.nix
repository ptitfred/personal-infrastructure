{ config, lib, ... }:

let cfg = config.services.ptitfred.personal-homepage;

in

{
  services.nginx.enable = cfg.enable;

  networking.firewall.allowedTCPPorts = lib.mkIf cfg.enable (if cfg.secure then [ 80 443 ] else [ 80 ]);
}
