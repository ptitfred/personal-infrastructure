# Lix for nix-prefetch-url
{ writeShellApplication, httpie, jq, lix }:

writeShellApplication {
  name = "obsidian-updater";
  runtimeInputs = [ httpie jq lix ];
  text = builtins.readFile ./updater.sh;
}
