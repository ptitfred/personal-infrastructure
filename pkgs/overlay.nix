final: prev:

{
  backgrounds      = final.callPackage ./backgrounds     {};
  flake-updater    = final.callPackage ./flake-updater   {};
  generic-updater  = final.callPackage ./generic-updater {};
}
