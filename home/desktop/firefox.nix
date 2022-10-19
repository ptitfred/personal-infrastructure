{ ... }:

let mkAnonymousFirefoxProfile = id: {
      inherit id;
      settings = {
        "intl.accept_languages" = "fr, fr-FR, en-US, en";
        "intl.locale.requested" = "fr, en-US";
      };
    };

    mkFirefoxProfile = id: username: (mkAnonymousFirefoxProfile id) // {
      settings = {
        "services.sync.username" = username;
      };
    };
in
  {
    programs.firefox = {
      enable = true;
      profiles = {
        perso = mkFirefoxProfile 0 "frederic.menou@gmail.com";
        pro = mkFirefoxProfile 1 "frederic.menou@fretlink.com";
        screenshots = mkAnonymousFirefoxProfile 2;
      };
    };
  }
