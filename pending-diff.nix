{ writeShellApplication
, nvd
, colmena
, coreutils
, jq
}:

writeShellApplication {
  name = "pending-diff";
  runtimeInputs = [ nvd colmena coreutils jq ];
  text = builtins.readFile ./pending-diff.sh;
}
