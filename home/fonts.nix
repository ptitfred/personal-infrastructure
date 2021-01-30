rec {
  roboto = { name = "Roboto"; size = "9"; };

  toPolybar = { name, size }: "${name}:size=${size}";
  toI3      = { name, size }: "${name} ${size}";
  toXFT     = { name, size }: "xft:${name}:pixelsize=${size}";
  toGTK = toI3;
}
