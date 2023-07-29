{ writeShellApplication
, lightdm
}:

writeShellApplication {
  name = "locker";
  runtimeInputs = [ lightdm ];
  text = "dm-tool lock";
}
