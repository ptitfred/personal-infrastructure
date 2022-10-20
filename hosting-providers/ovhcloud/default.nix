{ config, lib, ... }:

with lib;

{
  imports = [
    ./hardware-configuration.nix
  ];

  options.cloud-providers.ovh = {
    root-ssh-key = mkOption {
      type = types.str;
      description = ''
        SSH public key to grant the root user;
      '';
    };
  };

  config = {
    boot.cleanTmpDir = true;
    zramSwap.enable = true;
    services.openssh.enable = true;

    users.users.root.openssh.authorizedKeys.keys = [
      config.cloud-providers.ovh.root-ssh-key
    ];
  };
}
