{ pkgs, ... }:

{
  home.packages = with pkgs; [
      qemu
      weechat
      shutter
    ];
}
