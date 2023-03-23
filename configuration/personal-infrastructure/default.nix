{ ... }:

{
  imports = [
    ./acme.nix
    ./fail2ban.nix
    ./matomo.nix
    ./nix-cache.nix
    ./security.nix
    ./wireguard.nix
  ];
}
