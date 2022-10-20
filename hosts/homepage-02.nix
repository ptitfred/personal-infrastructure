{ ... }:

{
  imports = [
    ../hosting-providers/gandicloud.nix
    ../configuration/acme.nix
    ../configuration/fail2ban.nix
  ];

  networking.hostName = "homepage-02";

  system.stateVersion = "22.05";
}
