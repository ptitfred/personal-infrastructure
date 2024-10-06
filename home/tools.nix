{ callPackage, linkFarm }:

let hm-tools = {
      rofi-screenshot    = callPackage desktop/rofi-screenshot     {};
      backgrounds        = callPackage desktop/backgrounds         {};
      toggle-redshift    = callPackage desktop/toggle-redshift.nix {};
      focus-by-classname = callPackage desktop/focus-by-classname  {};
      aeroplane-mode     = callPackage desktop/aeroplane-mode      {};
    };
 in hm-tools // {
      default = linkFarm "tools" hm-tools;
    }
