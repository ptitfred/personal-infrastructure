{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.personal-website;
  sources = import ../nix/sources.nix;

  root =
    pkgs.callPackage (sources.personal-homepage + "/website/package.nix")
      { baseUrl = "https://${cfg.domain}"; };

  extraConfig = ''
    error_page 404 /404.html;
  '';

  mkRedirect = alias: vhosts: vhosts // redirect alias;

  redirect =
    alias:
      {
        "${alias}" = {
          useACMEHost = cfg.domain;
          locations."/" = {
            return = "301 https://${cfg.domain}$request_uri";
          };
        };
      };

  hostingHost =
    {
      ${cfg.domain} = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          inherit root extraConfig;
        };
      };
    };

  virtualHosts = foldr mkRedirect hostingHost cfg.aliases;
in
  {
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
          CNAMEs to respond to by redirecting to the domain set at `services.personal-website.domain`;
        '';
        default = [];
      };
    };

    config = mkIf cfg.enable {
      services.nginx = {
        enable = true;
        inherit virtualHosts;
      };

      networking.firewall.allowedTCPPorts = [ 80 443 ];

      security.acme.certs.${cfg.domain}.extraDomainNames = cfg.aliases;
    };
  }
