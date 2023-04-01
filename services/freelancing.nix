{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.freelancing;
  brotlify = pkgs.callPackage ./brotlify.nix { };

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
          root = brotlify { src = cfg.root; };
          inherit (cfg) extraConfig;
        };
      };
    };

  virtualHosts = foldr mkRedirect hostingHost cfg.aliases;
in
  {
    options.services.freelancing = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, hosts my freelancing website on this machine.
        '';
      };

      root = mkOption {
        type = types.path;
        example = "/data/webserver/docs";
        description = lib.mdDoc ''
          The path of the web root directory.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = lib.mdDoc ''
          These lines go to the end of the vhost verbatim.
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
      };

      networking.firewall.allowedTCPPorts = [ 80 443 ];

      security.acme.certs.${cfg.domain}.extraDomainNames = cfg.aliases;
    };
  }
