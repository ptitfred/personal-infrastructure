{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    boot.cleanTmpDir = true;
    zramSwap.enable = true;
  };
}
