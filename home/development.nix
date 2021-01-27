{ pkgs, ... }:

{
  imports = [
    development/shell.nix
    development/neovim.nix
    development/git.nix
  ];

  home = {
    packages = with pkgs; [
      gnumake
      httpie
      jq
      shellcheck
      posix-toolbox.wait-tcp
    ];
  };

}
