{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wireguard
    bind
  ];
}
