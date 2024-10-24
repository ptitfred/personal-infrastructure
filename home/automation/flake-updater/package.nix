{ writeShellApplication
, bash
, coreutils
, gh
, git
, gnugrep
, gnused
, jq
, just
, nix
, openssh
}:

writeShellApplication {
  name = "flake-updater";
  runtimeInputs = [ bash coreutils gh git gnugrep gnused jq just nix openssh ];
  text = builtins.readFile ./script.sh;
}
