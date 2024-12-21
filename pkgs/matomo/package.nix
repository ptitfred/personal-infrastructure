{ fetchurl, matomo_5, url, version, sha256, ... }:

matomo_5.overrideAttrs {
  name = "matomo_5-${version}";
  inherit version;
  src = fetchurl {
    inherit url sha256;
  };
}
