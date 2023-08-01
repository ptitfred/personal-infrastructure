{ pkgs, ... }:

let material-symbols =
      pkgs.material-symbols.overrideAttrs {
        src =
          pkgs.fetchFromGitHub {
            owner = "google";
            repo = "material-design-icons";
            rev = "6745d95590b1a5593888b6c402401fc3db75fbdb";
            sha256 = "sha256-xO/LDM1OYfVJ1uQEZRvhS11+ytUVrbqFtVCb98kSLyk=";
            sparseCheckout = [ "variablefont" ];
          };
      };
in
{
  home.packages = [ pkgs.roboto material-symbols ];

  fonts.fontconfig.enable = true;
}
