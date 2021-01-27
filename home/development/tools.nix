{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnumake
    httpie
    jq
    shellcheck
    posix-toolbox.wait-tcp
  ];
}
