{ config, lib, ... }:

with lib;

let mkAnonymousFirefoxProfile = id: {
      inherit id;
      settings = {
        "intl.accept_languages" = "fr, fr-FR, en-US, en";
        "intl.locale.requested" = "fr, en-US";
      };
    };

    mkFirefoxProfile = username: id: (mkAnonymousFirefoxProfile id) // {
      settings = {
        "services.sync.username" = username;
      };
    };

    mkProfiles = profiles:
      let userProfiles = attrsets.zipAttrsWith (_: builtins.head) (index unindexedProfiles);
          index = lists.imap0 applyIndex;
          unindexedProfiles = attrsets.mapAttrsToList (n: e: { "${n}" = mkFirefoxProfile e; } ) profiles;
          applyIndex = i: attrsets.mapAttrs (_: v: v i);
          screenshotProfile = {
            screenshots = mkAnonymousFirefoxProfile (builtins.length (attrsets.attrValues profiles));
          };
      in userProfiles // screenshotProfile;
in
  {
    options = {
      desktop.firefox.profiles = mkOption {
        type = types.attrsOf types.str;
        default = {};
      };
    };

    config = {
      programs.firefox = {
        enable = true;
        profiles = mkProfiles config.desktop.firefox.profiles;
      };
    };
  }
