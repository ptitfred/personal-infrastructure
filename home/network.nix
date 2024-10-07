{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wireguard-tools
    bind
  ];

  home.file = {
    ".digrc".text = ''
      +noall +answer
    '';
  };
}
