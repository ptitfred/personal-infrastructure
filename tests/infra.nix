import ../infrastructure.nix {
  domain = "test.localhost";
  aliases = [ "localhost" "test2.localhost" ];
  acme-email = "acme@localhost";
  safe-ips = [ "1.1.1.1" ];
  ssh-keys = {
    local  = builtins.readFile ./key.pub;
    remote = builtins.readFile ./key.pub;
  };
}
