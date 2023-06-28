{ ... }:
{
  imports = [
    hosts/homepage-02.nix
    configuration/personal-infrastructure
    morph-utils/monitor-nginx.nix
    services/website.nix
    services/freelancing.nix
  ];

  config = {
    services.personal-website = {
      enable = true;
    };

    personal-infrastructure = {
      fail2ban.enable = true;
      matomo.enable = true;

      tissue = {
        publicKey = "WHQ/KKdGP/iuE7ii1lLVq45VKiV4nOdHFSioa1U/XXA=";
        ip = "10.100.0.1";
        clients = [ "dev-01" "homepage-03" ];
      };
    };
  };

}
