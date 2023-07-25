{ nix-linter
, writeShellApplication
}:

writeShellApplication {
  name = "lint";
  runtimeInputs = [ nix-linter ];
  text = ''
    set -e
    find . -type f -name "*.nix" -exec nix-linter {} + && echo "Everything is fine!"
  '';
}
