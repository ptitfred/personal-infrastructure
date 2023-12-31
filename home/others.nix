{ pkgs, lib, ... }:

let obsidian = pkgs.callPackage ./obsidian.nix {
      version = "1.5.3";
      sha256 = "sha256-F7nqWOeBGGSmSVNTpcx3lHRejSjNeM2BBqS9tsasTvg=";
    };
in
{
  home.packages = with pkgs; [
      qemu
      weechat
      slack
      ncdu
      gimp
      obsidian
    ];

  nixpkgs.config.allowUnfree = true;

  # Necessary for flakes, see https://github.com/nix-community/home-manager/issues/2942#issuecomment-1119760100
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "slack" "obsidian" ];

  # Electron version 25.9.0 is EOL but is used by obsidian.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
