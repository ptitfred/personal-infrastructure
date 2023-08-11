{ pkgs, lib, ... }:

let obsidian = pkgs.callPackage ./obsidian.nix {
      version = "1.3.7";
      sha256 = "sha256-8Qi12d4oZ2R6INYZH/qNUBDexft53uy9Uug7UoArwYw=";
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
}
