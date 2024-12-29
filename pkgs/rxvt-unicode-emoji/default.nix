{ rxvt-unicode-emoji, rxvt-unicode-unwrapped-emoji }:

let rxvt-unicode-unwrapped =
      rxvt-unicode-unwrapped-emoji.overrideAttrs(_: previous:
        { patches = [ ./fix-OSC-commands.patch ] ++ previous.patches; }
      );
 in rxvt-unicode-emoji.override { inherit rxvt-unicode-unwrapped; }
