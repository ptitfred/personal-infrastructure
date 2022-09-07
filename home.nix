{ ... }:

let optionalImport = path : if builtins.pathExists path then [ path ] else [];
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
}
