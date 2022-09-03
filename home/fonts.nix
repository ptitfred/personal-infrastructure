rec {
  roboto = { name = "Roboto"; size = 9; };

  toPolybar = { name, size }: "${name}:size=${toString size}";
  toI3      = { name, size }: { names = [ name ]; size = size * 1.0; };
  toXFT     = { name, size }: "xft:${name}:pixelsize=${toString size}";
  toGTK      = { name, size }: "${name} ${toString size}";
}
