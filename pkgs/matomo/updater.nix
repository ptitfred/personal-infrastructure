{ writeShellApplication, generic-updater, httpie }:

writeShellApplication {
  name = "matomo-updater";
  runtimeInputs = [ generic-updater httpie ];
  text = builtins.readFile ./updater.sh;
}
