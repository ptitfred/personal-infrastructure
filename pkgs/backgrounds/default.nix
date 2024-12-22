{ runCommand
}:

runCommand "backgrounds" {
  src = ./.;
} ''
  mkdir -p $out
  cp $src/*.jpg $out
''
