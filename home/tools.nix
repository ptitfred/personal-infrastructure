{ callPackage }:

{
  rofi-screenshot    = callPackage desktop/rofi-screenshot     {};
  toggle-redshift    = callPackage desktop/toggle-redshift.nix {};
  focus-by-classname = callPackage desktop/focus-by-classname  {};
  aeroplane-mode     = callPackage desktop/aeroplane-mode      {};
}
