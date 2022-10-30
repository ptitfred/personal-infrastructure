{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    security.personal-infrastructure.root-ssh-keys = mkOption {
      type = types.listOf types.str;
      description = ''
        SSH public keys to grant the root user.
      '';
    };
  };

  config = {
    services.openssh.enable = true;

    users.users.root.openssh.authorizedKeys.keys =
      if builtins.length config.security.personal-infrastructure.root-ssh-keys > 0
      then config.security.personal-infrastructure.root-ssh-keys
      else abort "${config.networking.hostName}: At least 1 ssh authorized keys must be provided or we'll lose access to the server."
      ;

    # FIXME: Remove it once 3.0.x has been released with the critical fix on 2022-11-01
    services.nginx.package = pkgs.nginxStable.override { openssl = pkgs.openssl_1_1; };
  };
}
