{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
      qemu
      weechat
      slack
      shutter
      ncdu
    ];

  nixpkgs.config.allowUnfree = true;

  # Necessary for flakes, see https://github.com/nix-community/home-manager/issues/2942#issuecomment-1119760100
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "slack" ];
}
