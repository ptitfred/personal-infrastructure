{ writeShellApplication
, bash
, coreutils
, git
, just
, nix
, openssh
}:

writeShellApplication {
  name = "flake-updater";
  runtimeInputs = [ bash coreutils git just nix openssh ];
  text = builtins.readFile ./script.sh;
}
