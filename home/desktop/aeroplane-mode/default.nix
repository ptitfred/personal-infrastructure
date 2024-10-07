{ writeShellApplication
, networkmanager
}:

writeShellApplication {
  name = "aeroplane-mode-toggle";
  runtimeInputs = [ networkmanager ];
  text = builtins.readFile ./script.sh;
}
