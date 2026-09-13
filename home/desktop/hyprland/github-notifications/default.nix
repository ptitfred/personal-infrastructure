{ writeShellApplication, curl, jq
, githubTokenFile
}:

writeShellApplication {
  name = "waybar-github-notifications-module";

  runtimeInputs = [ curl jq ];

  text = ''
    TOKEN=$(<${githubTokenFile})
    ${builtins.readFile ./script.sh}
  '';
}
