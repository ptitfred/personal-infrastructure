{ config, lib, ... }:

with lib;

let cfg = config.personal-infrastructure.fail2ban;
in
{
  options.personal-infrastructure.fail2ban = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    safe-ips = mkOption {
      type = types.listOf types.str;
      description = ''
        List of IPV4 addresses to exclude from fail2ban.
      '';
      default = [];
    };
  };

  config.services.fail2ban = mkIf cfg.enable {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ] ++ cfg.safe-ips;
  };
}
