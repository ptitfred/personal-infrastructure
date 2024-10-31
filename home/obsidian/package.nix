{ fetchurl, obsidian, url, version, sha256 }:

obsidian.overrideAttrs {
  src = fetchurl { inherit url sha256; };
  inherit version;
}
