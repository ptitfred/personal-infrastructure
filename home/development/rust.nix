{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cargo
    cargo-watch
    clippy
    gcc
    rust-analyzer
    rustc
    rustfmt
  ];
}
