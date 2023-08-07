{ config, lib, pkgs, ... }:

with lib;

let
  enabled = config.services.nginx.enable && config.services.nginx.brotliSupport;
in
  {
    options.services.nginx.brotliSupport = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If true, nginx will be configured to support Brotli compression.
      '';
    };

    config = mkIf enabled {
      services.nginx.additionalModules = [ pkgs.nginxModules.brotli ];
      services.nginx.appendHttpConfig = ''
          brotli on;
          brotli_comp_level 6;
          brotli_static on;
          brotli_types application/atom+xml application/javascript application/json application/rss+xml
                 application/vnd.ms-fontobject application/x-font-opentype application/x-font-truetype
                 application/x-font-ttf application/x-javascript application/xhtml+xml application/xml
                 font/eot font/opentype font/otf font/truetype image/svg+xml image/vnd.microsoft.icon
                 image/x-icon image/x-win-bitmap text/css text/javascript text/plain text/xml;
        '';
    };
  }
