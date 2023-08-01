{ writeShellApplication
, nvd
, colmena
, coreutils
, jq
, nix
, openssh
}:

writeShellApplication {
  name = "pending-diff";
  runtimeInputs = [ nvd colmena coreutils jq nix openssh ];
  text = builtins.readFile ./script.sh;
}
