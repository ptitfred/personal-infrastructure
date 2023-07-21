# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDqSq+a5NEWhJGzdjvKNGv0/EQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    substituters = [
      "https://cache.iog.io"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org/"
    ];
  };

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    displayManager = {
      sddm.enable = lib.mkForce false;
      lightdm.enable = true;
      autoLogin.enable = lib.mkForce false;
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };

    layout = "fr";
  };

  # Configure keymap in X11
  # services.xserver.layout = "fr";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  networking.hostName = "dev-01";

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
  #   font = "Lat2-Terminus16";
    keyMap = "fr";
  #   useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.frederic = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
      "vboxsf"
    ];
  };

  # Add docker
  virtualisation.docker.enable = true;

  # home-manager.users.frederic = { pkgs, ... }: {
  #   home.packages = [ pkgs.git pkgs.home-manager ];
  #   programs.bash.enable = true;
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Fancy boot screen
  boot.plymouth.enable = true;

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  programs.ssh.startAgent = true;

  services.dbus.packages = with pkgs; [ dconf ];
  programs.dconf.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 1111 8000 8080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Tailscale
  services.tailscale.enable = false;
  networking.firewall.checkReversePath = "loose";
  networking.nameservers = [
    # "100.100.100.100"
    "8.8.8.8"
    "1.1.1.1"
  ];
  # networking.search = [ "frederic-menou.gmail.com.beta.tailscale.net" ];

  services.prometheus.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "8192";
    }
  ];

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIEJTCCAw2gAwIBAgIUev7YHE0WtVUUGhmWwf7s5TT46PEwDQYJKoZIhvcNAQEL
      BQAwgaExCzAJBgNVBAYTAkZSMQwwCgYDVQQIDANJZEYxDTALBgNVBAcMBEx5b24x
      FjAUBgNVBAoMDVNvZnR3YXJlIENsdWIxEzARBgNVBAsMCmRldmVsb3BlcnMxHzAd
      BgNVBAMMFkZyZWRlcmljJ3MgV29ya3N0YXRpb24xJzAlBgkqhkiG9w0BCQEWGGZy
      ZWRlcmljQHNvZnR3YXJlY2x1Yi5pbzAeFw0yMzAxMjgxMzU2NTlaFw0yODAxMjcx
      MzU2NTlaMIGhMQswCQYDVQQGEwJGUjEMMAoGA1UECAwDSWRGMQ0wCwYDVQQHDARM
      eW9uMRYwFAYDVQQKDA1Tb2Z0d2FyZSBDbHViMRMwEQYDVQQLDApkZXZlbG9wZXJz
      MR8wHQYDVQQDDBZGcmVkZXJpYydzIFdvcmtzdGF0aW9uMScwJQYJKoZIhvcNAQkB
      FhhmcmVkZXJpY0Bzb2Z0d2FyZWNsdWIuaW8wggEiMA0GCSqGSIb3DQEBAQUAA4IB
      DwAwggEKAoIBAQDabvP+pDGl/8U35Tp8UlyEW2Cc+ln0JgNp2+Nn8mOih8xu7tAX
      f3qwIjgFYOO3sdPB/ksq1XD9cOli8IdRfD/YMA7O36vHXVG42DkwbuON6otvw6h9
      MEXUkZA2I/DOpw8ctxZcKoqVYRWgTnDxMmdjToX5KlTPrYo9tkxlCblozTfZ35Vr
      a4PF74S/voPiAdEObCUG2b0ly67Q1dZMK2pO7g7Z7qikGZI/x4V+PBRjpo3fMn5M
      gScPHYQERqDU1bUDE4G5NPoYXSrf0ceSy7JAo1z6fWvTDRHrX80vKZTR5EmbfW6c
      JMzdGt/2CVI+fQ5t7IT89l7OK/ASk8wXA6C1AgMBAAGjUzBRMB0GA1UdDgQWBBRJ
      3BLABeDQEIJVQTVp7rXX2io1iDAfBgNVHSMEGDAWgBRJ3BLABeDQEIJVQTVp7rXX
      2io1iDAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCUihUjr4zG
      MVWBzxSjnM0ZbTpJJyjw8nhF2e/evunPqPDDgQuVH6lz5AtL4rQ4CWYQdBYP9ZrZ
      S8By1rRaeBwDH+1q8yqx1h6rQnmDDzLZlWB2SnAgmMIMEA6luCmQGApUOrdaHUko
      SWb1fnk5WwqVpXe8idmuwtLpTHY7wPo8zGBw+wKrlG5oaN9SCG3FqzFAB7Rbgt3B
      C0x8WjMZkBBj8luvQN118JgzlabLIEOuixzx/f7XdJ2zfVacZk4El7P0Bb3BHP+r
      9dv0Otu5BHjSv7uqoi+2ujlT2KFjw6uFSRFpA2Molyl8HU1wCQUJ4mHvzUjmcFHF
      cxnpAsuyRJOd
      -----END CERTIFICATE-----
    ''
  ];

  nix.settings.trusted-users = [ "root" "frederic" ];
}
