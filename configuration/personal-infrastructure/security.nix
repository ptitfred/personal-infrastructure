{ config, lib, ... }:

with lib;

{
  options = {
    personal-infrastructure.root-ssh-keys = mkOption {
      type = types.listOf types.str;
      description = ''
        SSH public keys to grant the root user.
      '';
    };
  };

  config = {
    services.openssh.enable = true;

    users.users.root.openssh.authorizedKeys.keys =
      if builtins.length config.personal-infrastructure.root-ssh-keys > 0
      then config.personal-infrastructure.root-ssh-keys
      else abort "${config.networking.hostName}: At least 1 ssh authorized keys must be provided or we'll lose access to the server."
      ;
  };
}
