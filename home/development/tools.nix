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
    unzip
    hey
    wget
    tabiew
    psmisc
  ];
}
