{ ... }:

{
  imports = [
    ../hosting-providers/ovhcloud
    ../configuration/fail2ban.nix
  ];

  networking.hostName = "homepage-03";

  system.stateVersion = "22.05";
}
