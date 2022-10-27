{ ... }:

let optionalImport = path : if builtins.pathExists path then [ path ] else [];
    orange = "#ffb52a";
in

{
  imports = [
    home/nix.nix
    home/home-manager.nix
    home/desktop.nix
    home/development
    home/network.nix
    home/others.nix
  ] ++ optionalImport home/private.nix;

  desktop = {
    mainColor = orange;
    location =
      {
        latitude = "45.7578";
        longitude = "4.8322";
      };
    spacing = 10;
  };
}
