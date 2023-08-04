{ callPackage
, nix-linter
}:

{
  lint         = callPackage ./lint.nix     { inherit nix-linter; };
  metadata     = callPackage ./metadata     {};
  pending-diff = callPackage ./pending-diff {};
}
