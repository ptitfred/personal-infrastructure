{ callPackage, inputs }:

{
  metadata      = callPackage ./metadata     {};
  pending-diff  = callPackage ./pending-diff {};
  scram-sha-256 = callPackage ./scram-sha-256.nix { inherit inputs; };
}
