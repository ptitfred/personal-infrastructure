{ pkgs, ... }:

{
  home.packages = with pkgs; [
      qemu
      weechat
      slack
      shutter
      ncdu
    ];

  nixpkgs.config.allowUnfree = true;
}
