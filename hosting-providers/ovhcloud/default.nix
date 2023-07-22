{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = true;
  };
}
