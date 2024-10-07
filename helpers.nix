{ lib, runCommand, symlinkJoin, ... }:


let dropOverrides =
      let dropOverride = name: _: ! builtins.elem name [ "override" "overrideDerivation"];
       in lib.attrsets.filterAttrs dropOverride;

    bundleTools = tools:
      let default = symlinkJoin { name = "tools"; paths = builtins.attrValues tools; };
      in tools // { inherit default; };

    mkCheck = name: script:
      runCommand name {} ''
        mkdir -p $out
        ${script}
      '';

    mkChecks = lib.attrsets.mapAttrs mkCheck;

in { inherit dropOverrides bundleTools mkChecks; }
