{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
      qemu
      weechat
      ncdu
      gimp
      obsidian
    ];

  nixpkgs.config.allowUnfree = true;

  # Necessary for flakes, see https://github.com/nix-community/home-manager/issues/2942#issuecomment-1119760100
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "obsidian" ];

  # Electron version 25.9.0 is EOL but is used by obsidian.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
