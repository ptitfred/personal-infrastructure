{ config, lib, ... }:

with lib;

{
  options.security.personal-infrastructure = {
    safe-ips = mkOption {
      type = types.listOf types.str;
      description = ''
        List of IPV4 addresses to exclude from fail2ban.
      '';
      default = [];
    };
  };

  config.services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ] ++ config.security.personal-infrastructure.safe-ips;
  };
}
