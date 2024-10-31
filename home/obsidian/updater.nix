# Lix for nix-prefetch-url
{ writeShellApplication, gh, jq, lix }:

writeShellApplication {
  name = "obsidian-updater";
  runtimeInputs = [ gh jq lix ];
  text = builtins.readFile ./updater.sh;
}
