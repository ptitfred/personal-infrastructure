{ pkgs, ... }:

{
  home.packages = with pkgs; [
    posix-toolbox.git-bubbles
    posix-toolbox.git-checkout-log
  ];

  programs.bash = {
    initExtra = ''
      source ${pkgs.posix-toolbox.git-ps1}/share/posix-toolbox/git-ps1
    '';
  };

  programs.git = {
    enable = true;

    userName = "Frédéric Menou";
    userEmail = "frederic.menou@gmail.com";

    aliases = rec {
      st        = "status -sb";
      plog      = "log --oneline --decorate --graph";
      slog      = "log --format=short --decorate --graph";
      qu        = "log HEAD@{u}... --oneline --decorate --graph --boundary";
      qus       = qu + " --stat";
      quc       = "log HEAD@{u}..  --oneline --decorate --graph";
      qux       = quc + " --stat";
      pq        = "log HEAD@{u}... --oneline --decorate --graph --patch";
      pqr       = "log HEAD@{u}... --oneline --decorate         --patch --reverse";
      review    = "rebase -i --autosquash";
      rework    = review + " --autostash";
      pdiff     = "diff -w --word-diff=color";
      pshow     = "show -w --word-diff=color";
      fop       = "fetch --prune origin";
      ls-others = "ls-files -o --exclude-standard";
    };

    extraConfig = {
      pull.rebase = true;
      bubbles.remote-name = "mine";
      http.sslcainfo = "/etc/ssl/certs/ca-bundle.crt";
    };
  };
}
