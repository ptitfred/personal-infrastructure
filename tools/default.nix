{ callPackage }:

{
  lint         = callPackage ./lint.nix     {};
  metadata     = callPackage ./metadata     {};
  pending-diff = callPackage ./pending-diff {};
}
