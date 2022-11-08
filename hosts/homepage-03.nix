{ ... }:

{
  imports = [
    ../hosting-providers/ovhcloud
  ];

  networking.hostName = "homepage-03";

  system.stateVersion = "22.05";
}
