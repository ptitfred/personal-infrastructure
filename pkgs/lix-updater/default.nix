{ writeShellApplication, coreutils, git, gnugrep, gnused, httpie, jq, yq }:

writeShellApplication {
   name = "lix-input-updater";
   runtimeInputs = [ coreutils git gnugrep gnused httpie jq yq ];
   text = builtins.readFile ./script.sh;
}
