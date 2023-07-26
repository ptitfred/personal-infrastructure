{ writeShellApplication
, scrot
, xclip
}:

writeShellApplication {
  name = "screenshot";
  runtimeInputs = [ scrot xclip ];
  text = builtins.readFile ./screenshot.sh;
}
