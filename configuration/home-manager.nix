home-manager:

{ ... }:
{
  imports = [
    home-manager.nixos
  ];
  environment.systemPackages = [ home-manager.home-manager ];
}
