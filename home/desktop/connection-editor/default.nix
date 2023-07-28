{ writeShellApplication
, coreutils
, i3
, networkmanagerapplet
, xdotool
}:

writeShellApplication {
  name = "floating-nm-connection-editor";
  runtimeInputs = [ coreutils i3 networkmanagerapplet xdotool ];
  text = builtins.readFile ./script.sh;
}
