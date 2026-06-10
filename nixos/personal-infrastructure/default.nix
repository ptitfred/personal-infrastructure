{ pkgs, ... }:

{
  imports = [
    ./acme.nix
    ./fail2ban.nix
    ./matomo
    ./nix-cache.nix
    ./security.nix
    ./wireguard.nix
    ./postgresql.nix
  ];

  # See https://lix.systems/add-to-config/#advanced-change
  nix.package = pkgs.lixPackageSets.stable.lix;
}
