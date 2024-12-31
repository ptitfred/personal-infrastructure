{ callPackage }:

{
  rofi-screenshot    = callPackage desktop/i3/rofi-screenshot     {};
  toggle-redshift    = callPackage desktop/i3/toggle-redshift.nix {};
  focus-by-classname = callPackage desktop/i3/focus-by-classname  {};
  aeroplane-mode     = callPackage desktop/i3/aeroplane-mode      {};
}
