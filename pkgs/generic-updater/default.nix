# Lix for nix-prefetch-url
{ writeShellApplication, git, jq, lix }:

writeShellApplication {
  name = "generic-updater";
  runtimeInputs = [ git jq lix ];
  text = builtins.readFile ./script.sh;
}
