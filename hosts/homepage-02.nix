{ ... }:

{
  imports = [
    ../hosting-providers/gandicloud.nix
  ];

  networking.hostName = "homepage-02";

  system.stateVersion = "22.05";
}
