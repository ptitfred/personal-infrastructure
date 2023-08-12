{ callPackage
, nixpkgs
, fetchpatch
}:

let base = callPackage (nixpkgs + "/pkgs/applications/terminal-emulators/rxvt-unicode") {};

    fetchPatchFromAUR = { package, name, sha256 }:
      fetchpatch rec {
        url = "https://aur.archlinux.org/cgit/aur.git/plain/${name}?h=${package}";
        extraPrefix = "";
        inherit name sha256;
      };

    truecolor-patch = fetchPatchFromAUR {
       package = "rxvt-unicode-truecolor";
       name = "24-bit-color.patch";
       sha256 = "sha256-VIuviqB9rgf6C7RsHj8VXcoXbewmMpJqAVZSpAZO/oA=";
    };
 in base.overrideAttrs(_: previous: {
      patches = previous.patches ++ [ truecolor-patch ];
      configureFlags = [ "--enable-24-bit-color" ];
    })
