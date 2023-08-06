{ infrastructure, ... }:
{
  deployment.tags = [ "web" ];

  imports = [
    hosts/homepage-02.nix
    configuration/personal-infrastructure
    morph-utils/monitor-nginx.nix
    services/website.nix
  ];

  services.personal-website = {
    enable = true;
    inherit (infrastructure) domain aliases;
  };

  personal-infrastructure = {
    inherit (infrastructure) acme-email;

    fail2ban = {
      enable = true;
      inherit (infrastructure) safe-ips;
    };

    matomo = {
      enable = true;
      hostname = infrastructure.matomo-hostname;
    };

    root-ssh-keys = [ infrastructure.ssh-keys.remote ];

    tissue = {
      publicKey = "WHQ/KKdGP/iuE7ii1lLVq45VKiV4nOdHFSioa1U/XXA=";
      ip = "10.100.0.1";
      clients = [ "dev-01" "dev-02" "homepage-03" ];
      listenIp = infrastructure.resolver.homepage-02;
      other-peers = infrastructure.wg-peers;
    };
  };
}
