{ config, lib, ... }:


let
  checks =
    if config.services.nginx.enable
    then lib.concatMap httpChecksFromVirtualHost (builtins.attrNames virtualHosts)
    else [];

  virtualHosts = config.services.nginx.virtualHosts;

  check = scheme: port: host:
    [
      {
        inherit scheme port host;
        description = "Check whether nginx is running on ${scheme} for host ${host}.";
      }
    ];

  httpChecksFromVirtualHost = host:
    if virtualHosts.${host}.enableACME || virtualHosts.${host}.useACMEHost != ""
    then check "http" 80 host ++ check "https" 443 host
    else check "http" 80 host
    ;

in

{
  imports = [ ./morph-compat.nix ];

  deployment.healthChecks.http = checks;
}
