{ ... }:
{
  imports = [
    hosts/homepage-03.nix
    configuration/personal-infrastructure
  ];

  config = {
    personal-infrastructure = {
      fail2ban = {
        enable = true;
      };

      nix-cache = {
        enable = true;
        domain = "cache.menou.me";
      };

      tissue = {
        publicKey = "jOab1ZoQrdbcNSN3qKTOOZ783CdtkCYSnMDXqqIWwXg=";
        ip = "10.100.0.2";
        host = "homepage-02";
        reachable = true;
      };
    };
  };
}
