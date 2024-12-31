{ writeShellApplication
, procps
}:

writeShellApplication {
  name = "toggle-redshift";
  runtimeInputs = [ procps ];
  text = "pkill -USR1 redshift-gtk";
}
