{ pkgs, ... }:

let check = name: assert pkgs.lib.attrsets.hasAttr name pkgs; name;
in
{
  home = {
    packages = with pkgs; [
      stack
    ];

    file = {
      # ghci
      ".ghci".text = ''
        :set prompt "λ> "
      '';

      ".stack/config.yaml".text =
        builtins.toJSON
          {
            nix = {
              pure = false;
              packages = map check [ "icu" "git" "postgresql_12_postgis" "unzip" "zlib" "gmp" "curl" ];
            };
          };
    };
  };

  programs.neovim.plugins =
    let neovim-ghcid = pkgs.vimUtils.buildVimPlugin {
        name = "ghcid";
        src = (pkgs.fetchFromGitHub {
          owner = "ndmitchell";
          repo = "ghcid";
          rev = "5d7f859bc6dd553bdf93e6453391353cf310e232";
          sha256 = "1gyasmk6k2yqlkny27wnc1fn2khphgv400apfh1m59pzd9mdgsc2";
        }) + "/plugins/nvim";
      };
    in [ neovim-ghcid ];
}
