{ writeShellApplication
, xdg-utils
, profile
}:

writeShellApplication {
  name = "browse";
  runtimeInputs = [ xdg-utils ];
  text = ''
    export PATH=${profile}/bin:$PATH
    xdg-open "$@"
  '';
}
