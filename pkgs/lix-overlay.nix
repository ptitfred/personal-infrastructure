# Patched following advice from matrix. The wiki is buggy and nobody seems to care.
# See <https://lix.systems/add-to-config/#advanced-change>.
# See <https://matrix.to/#/!9IQChSjwSHXPPWTa:lix.systems/$NHQ8odQgzmJdwUbj0BjS0lJ9tIpf8j1NEFksCH_z9RI?via=lix.systems&via=matrix.org&via=catgirl.cloud>

self: super: {
  inherit (self.lixPackageSets.stable) nixpkgs-review nix-direnv nix-fast-build nix-serve-ng colmena nix-update;
  lixPackageSets = super.lixPackageSets.override {
    inherit (super) nixpkgs-review nix-direnv nix-fast-build nix-serve-ng colmena nix-update;
  };
}
