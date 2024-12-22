{ writeShellApplication, generic-updater, gh, jq }:

writeShellApplication {
  name = "obsidian-updater";
  runtimeInputs = [ generic-updater gh jq ];
  text = builtins.readFile ./updater.sh;
}
