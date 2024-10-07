{ callPackage, inputs }:

{
  lint          = callPackage ./lint.nix     {};
  metadata      = callPackage ./metadata     {};
  pending-diff  = callPackage ./pending-diff {};
  scram-sha-256 = callPackage ./scram-sha-256.nix { inherit inputs; };
}
