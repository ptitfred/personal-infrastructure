{ config, ... }:

{
  desktop = {
    virtual-machine = false;
    mainColor = "#FF0000";
    location = { latitude = "44.0003"; longitude = "4.20001"; };
    spacing = 10;
    battery = {
      adapter = "ADC0";
      battery = "BAT0";
    };
  };

  home.username = "test";
  home.homeDirectory = "/home/test";

  ptitfred.automation.flake-updater.enable = true;
  ptitfred.automation.flake-updater.repositories = {
    personal-infrastructure = {
      gitRemoteUrl = "git@github.com:ptitfred/personal-infrastructure.git";
      githubTokenFile = "${config.home.homeDirectory}/.private/automat-github-token";
      localWorkingCopy = "${config.home.homeDirectory}/git/personal/infrastructure";
      interval = "24h";
    };
  };
}
