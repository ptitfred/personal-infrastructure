{ fetchurl, obsidian, url, version, sha256 }:

obsidian.overrideAttrs {
  src = fetchurl { inherit url sha256; };
  inherit version;
  commandLineArgs = "--no-sandbox --ozone-platform=wayland --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations %U";
}
