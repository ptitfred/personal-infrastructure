{ ... }:

{
  imports = [
    ./nix.nix
    ./home-manager.nix
    ./desktop
    ./development
    ./network.nix
    ./others.nix
  ];

  ptitfred.posix-toolbox.enable = true;
}
