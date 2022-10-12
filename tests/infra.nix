import ../infrastructure.nix {
  domain = "test.localhost";
  aliases = [ "localhost" "test2.localhost" ];
  acme-email = "acme@localhost";
}
