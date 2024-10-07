{ fetchurl
, obsidian
, version
, sha256
}:

let filename = "obsidian-${version}.tar.gz";
    src = fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/${filename}";
      inherit sha256;
    };
 in obsidian.overrideAttrs { inherit src version; }
