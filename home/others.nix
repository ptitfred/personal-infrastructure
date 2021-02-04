{ pkgs, ... }:

{
  home.packages = with pkgs; [
      qemu
      weechat
      slack
      shutter
    ];

  nixpkgs.config.allowUnfree = true;
}
