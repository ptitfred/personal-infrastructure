{ ... }:

{
  imports = [
    ../hosting-providers/gandicloud.nix
    ../configuration/acme.nix
  ];

  networking.hostName = "homepage-02";

  system.stateVersion = "22.05";
}
