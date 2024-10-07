{ runCommand
, dejavu_fonts
, nerd-font-patcher
}:

# FIXME: I've tried including the material-symbols glyphs but FontForge coredump
runCommand "patched-monospace" {
  buildInputs = [ nerd-font-patcher ];
} ''
  mkdir -p $out/share/fonts/truetype
  nerd-font-patcher --outputdir $out/share/fonts/truetype \
    --mono \
    --fontawesome --fontawesomeext \
    --powerline --powerlineextra \
    ${dejavu_fonts}/share/fonts/truetype/DejaVuSansMono.ttf
''
