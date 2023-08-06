{ pkgs, ... }:

let # See https://github.com/zealdocs/zeal/issues/1518#issuecomment-1661587539
    faketimed-zeal = pkgs.writeShellApplication {
      name = "zeal";
      runtimeInputs = [ pkgs.libfaketime pkgs.zeal ];
      text = "faketime '2023-07-26 00:00:00' zeal";
    };
in
{
  home.packages = with pkgs; [
    gnumake
    httpie
    jq
    shellcheck
    posix-toolbox.wait-tcp
    faketimed-zeal
    just
  ];
}
