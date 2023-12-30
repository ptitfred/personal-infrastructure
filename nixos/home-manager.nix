{ inputs, pkgs, ... }:

let hm = inputs.home-manager-base.inputs.home-manager;
 in
{
  imports = [
    hm.nixosModules.home-manager
  ];
  environment.systemPackages = [ hm.packages.${pkgs.system}.home-manager ];
}
