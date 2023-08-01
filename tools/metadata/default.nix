{ writeShellApplication
, colmena
, yq-go
}:

writeShellApplication {
  name = "metadata";
  runtimeInputs = [ colmena yq-go ];
  text = builtins.readFile ./script.sh;
}
