{ writeShellApplication
, i3
, xdotool
}:

writeShellApplication {
  name = "focus-by-classname";
  runtimeInputs = [ i3 xdotool ];
  text = builtins.readFile ./script.sh;
}
