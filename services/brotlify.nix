{ stdenvNoCC
, lib
, brotli }:
{ src
, fileExtensions ? [
  "html" "js" "css" "json" "txt" "ttf" "ico" "wasm"
]}:
let
  findQuery = lib.flatten (lib.intersperse "-o"
    (map (ext: [ "-iname" (lib.escapeShellArg "*.${ext}") ]) fileExtensions));
in stdenvNoCC.mkDerivation {
  inherit src;
  # inherit (src) version;
  name = "${src.name}-brotlified";

  nativeBuildInputs = [
    brotli
  ];

  buildPhase = ''
    find . -type f,l \( \
      ${lib.concatStringsSep " " findQuery} \
      \) -print0 | xargs -0 -P $NIX_BUILD_CORES -I{} brotli -vZk {}
  '';

  installPhase = ''
    cp -r . $out
  '';
}
