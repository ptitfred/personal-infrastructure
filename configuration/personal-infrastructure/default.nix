{ ... }:

{
  imports = [
    ./acme.nix
    ./fail2ban.nix
    ./security.nix
    ./wireguard.nix
    ./nix-cache.nix
  ];
}
