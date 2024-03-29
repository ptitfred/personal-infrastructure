{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.personal-website;

  brotlify = pkgs.callPackage ./brotlify.nix { };

  nginx = pkgs.ptitfred.nginx.override { inherit baseUrl; };

  baseUrl = "https://${cfg.domain}";

  assetsDirectory = "homepage-extra-assets";
  screenshotsSubdirectory = "og";

  mkRedirect = alias: vhosts: vhosts // redirect alias;

  redirect =
    alias:
      {
        "${alias}" = {
          forceSSL = true;
          enableACME = true;
          acmeFallbackHost = cfg.domain;
          globalRedirect = cfg.domain;
        };
      };

  hostingHost =
    {
      ${cfg.domain} = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          root = brotlify { src = nginx.root; };
          inherit (nginx) extraConfig;
        };

        locations."/${screenshotsSubdirectory}/" = {
          root = "/var/lib/${assetsDirectory}";
          inherit (nginx) extraConfig;
        };
      };
    };

  virtualHosts = foldr mkRedirect hostingHost cfg.aliases;
in
  {
    imports = [
      ./brotli.nix
    ];

    options.services.personal-website = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, hosts my personal-website on this machine.
        '';
      };

      domain = mkOption {
        type = types.str;
        description = ''
          CNAME to respond to to host the website.
        '';
      };

      aliases = mkOption {
        type = types.listOf types.str;
        description = ''
          CNAMEs to respond to by redirecting to the domain set at `services.personal-website.domain`.
        '';
        default = [];
      };
    };

    config = mkIf cfg.enable {
      services.nginx = {
        enable = true;
        inherit virtualHosts;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;
        brotliSupport = true;
      };

      networking.firewall.allowedTCPPorts = [ 80 443 ];

      systemd.services.homepage-screenshots = {
        description = "Utility to take screenshots at deployment.";

        after    = [ "nginx.service" ];
        requires = [ "nginx.service" ];
        wantedBy = [ "default.target" ];

        script = ''
          mkdir -p /var/lib/${assetsDirectory}/${screenshotsSubdirectory}
          ${pkgs.ptitfred.take-screenshots}/bin/take-screenshots ${baseUrl} /var/lib/${assetsDirectory}/${screenshotsSubdirectory}
        '';

        serviceConfig = {
          StateDirectory = assetsDirectory;
          StateDirectoryMode = "0750";
          User = "nginx";
          Group = "nginx";
          Type = "oneshot";
        };
      };

      security.acme.certs.${cfg.domain}.extraDomainNames = cfg.aliases;
    };
  }
