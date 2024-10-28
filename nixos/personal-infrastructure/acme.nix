{ config, lib, ... }:

with lib;

let cfg = config.personal-infrastructure;

in
{
  options.personal-infrastructure = {
    acme-email = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = mkIf (builtins.isString cfg.acme-email) {
    security.acme.acceptTerms = true;
    security.acme.defaults.email = cfg.acme-email;
  };
}
