{ ... }:

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
}
