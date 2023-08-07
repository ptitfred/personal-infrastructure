{ inputs, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  environment.systemPackages = [ inputs.home-manager.packages.${pkgs.system}.home-manager ];
}
