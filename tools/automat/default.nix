{ writeShellApplication
, git
, just
, nix
, githubTokenFile ? "/home/frederic/.private/automat-github-token"
, gitRemoteUrl ? "git@github.com:ptitfred/personal-infrastructure.git"
, localWorkingCopy ? "/home/frederic/git/personal/infrastructure"
}:

writeShellApplication {
  name = "automat";
  runtimeInputs = [ git just nix ];
  runtimeEnv = {
    inherit githubTokenFile gitRemoteUrl localWorkingCopy;
  };
  text = builtins.readFile ./script.sh;
}
