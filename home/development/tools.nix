{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnumake
    httpie
    jq
    shellcheck
    zeal
    just
    ripgrep
  ];
}
