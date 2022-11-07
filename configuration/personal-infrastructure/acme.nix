{ config, lib, ... }:

with lib;

let cfg = config.security.personal-infrastructure;

in
{
  options.security.personal-infrastructure = {
    acme-email = mkOption {
      type = types.str;
      default = null;
    };
  };

  config = mkIf (builtins.isString cfg.acme-email) {
    security.acme.acceptTerms = true;
    security.acme.defaults.email = cfg.acme-email;
  };
}
