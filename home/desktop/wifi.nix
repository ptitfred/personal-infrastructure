{ config, lib, pkgs, ... }:

let aeroplane-mode = pkgs.callPackage ./aeroplane-mode {};
 in
{
  config = lib.mkIf (! config.desktop.virtual-machine) {
    desktop.i3-extra-bindings = {
      "XF86RFKill" = "exec --no-startup-id ${aeroplane-mode}/bin/aeroplane-mode-toggle";
    };
  };
}
