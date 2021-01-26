{ pkgs, ... }:

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
    };
  };
}
