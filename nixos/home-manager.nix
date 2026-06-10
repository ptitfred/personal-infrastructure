{ inputs, pkgs, ... }:

let hm = inputs.home-manager;
 in
{
  imports = [
    hm.nixosModules.home-manager
  ];
  environment.systemPackages = [ hm.packages.${pkgs.stdenv.hostPlatform.system}.home-manager ];
}
