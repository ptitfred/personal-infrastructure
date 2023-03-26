{ pkgs ? import <nixpkgs> {}
}:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.morph pkgs.pwgen
  ];
}
