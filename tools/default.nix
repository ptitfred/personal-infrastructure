{ callPackage
, nix-linter
, symlinkJoin
}:

let tools = {
      lint         = callPackage ./lint.nix     { inherit nix-linter; };
      metadata     = callPackage ./metadata     {};
      pending-diff = callPackage ./pending-diff {};
    };
in tools // { default = symlinkJoin { name = "tools"; paths = builtins.attrValues tools; }; }
