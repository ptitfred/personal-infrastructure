{ baseSize }:

{
  palette = import ./palette.nix;
  fonts = import ./fonts.nix { inherit baseSize; };
}
