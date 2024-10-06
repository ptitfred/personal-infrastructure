{ pkgs
, writeShellApplication
, fetchgit
, timestamp ? "+%Y-%m-%d_%H%M%S"
, directory ? "$HOME/Pictures/screenshots"
, ...
}:

let src = fetchgit {
      url = "https://github.com/ceuk/rofi-screenshot";
      rev = "365cfa51c6c7deb072d98d7bfd68cf4038bf2737";
      sha256 = "sha256-M1cab+2pOjZ2dElMg0Y0ZrIxRE0VwymVwcElgzFrmVs=";
    };
    runtimeInputs = with pkgs; [ rofi ffmpeg ffcast slop xclip ];
in
  writeShellApplication {
    name = "rofi-screenshot";
    inherit runtimeInputs;
    text = ''
      ${src}/rofi-screenshot --timestamp "${timestamp}" --directory "${directory}" "$@"
    '';
  }
