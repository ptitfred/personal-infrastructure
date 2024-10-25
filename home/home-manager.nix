{ ... }:

{
  home.stateVersion = "22.11";

  news.display = "silent";

  # Automatically restart systemd services deemed necessary
  systemd.user.startServices = "sd-switch";
}
