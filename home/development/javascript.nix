{ pkgs, ... }:

{
  home = {
    file = {
      # disable optionals from npm to rely on nixos
      ".npmrc".text = ''
        optional = false
      '';
    };
  };
}
