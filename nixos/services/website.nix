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

  vhostRedirectionBaseDefinition = {
    forceSSL = cfg.secure;
    enableACME = cfg.secure;
    globalRedirect = cfg.domain;
  };

  vhostRedirectionOptionalDefinition =
    if cfg.secure
    then { acmeFallbackHost = cfg.domain; }
    else {};

  redirect = alias: {
    "${alias}" = vhostRedirectionBaseDefinition // vhostRedirectionOptionalDefinition;
  };

  mkRedirection = { path, target }: "rewrite ^${path}$ ${target} permanent;";

  extraConfig = ''
    ${nginx.extraConfig}
    ${lib.strings.concatMapStringsSep "\n" mkRedirection cfg.redirections}
  '';

  hostingHost =
    {
      ${cfg.domain} = {
        forceSSL = cfg.secure;
        enableACME = lib.mkIf cfg.secure true;

        locations."/" = {
          root = brotlify { src = nginx.root; };
          inherit extraConfig;
        };

        locations."/${screenshotsSubdirectory}/" = {
          root = "/var/lib/${assetsDirectory}";
        };
      };
    };

  virtualHosts = foldr mkRedirect hostingHost cfg.aliases;

  redirection = types.submodule {
    options = {
      path = mkOption {
        type = types.str;
        default = false;
      };
      target = mkOption {
        type = types.str;
        default = false;
      };
    };
  };
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

      secure = mkOption {
        type = types.bool;
        default = true;
        description = ''
          If enabled, sets up HTTPs and enforces it. Defaults to true.
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

      redirections = mkOption {
        type = types.listOf redirection;
        description = ''
          Extra URL redirections to inject and that you might not want to have publicly committed.
        '';
        default = [];
      };

      screenshots = mkEnableOption "screenshots" // { default = true; };
    };

    config = mkIf cfg.enable {
      services.nginx = {
        enable = true;
        inherit virtualHosts;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;
        brotliSupport = true;
      };

      networking.firewall.allowedTCPPorts = if cfg.secure then [ 80 443 ] else [ 80 ];

      systemd.services.homepage-screenshots = mkIf cfg.screenshots {
        description = "Utility to take screenshots.";

        after    = [ "nginx.service" ];
        requires = [ "nginx.service" ];
        partOf = [ "default.target" ];

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

      systemd.timers.homepage-screenshots = mkIf cfg.screenshots {
        description = "Utility to take screenshots.";
        timerConfig.OnCalendar = "02:00:00";
        wantedBy = [ "timers.target" ];
      };

      security.acme.certs.${cfg.domain} = lib.mkIf cfg.secure {
        extraDomainNames = lib.mkIf cfg.secure cfg.aliases;
      };
    };
  }
