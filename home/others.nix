{ pkgs, lib, ... }:

let obsidian = pkgs.callPackage ./obsidian.nix {
      version = "1.6.7";
      sha256 = "sha256-ok1fedN8+OXBisFpVXbKRW2OhE4o9MC9lJmtMMST6V8=";
    };
in
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
