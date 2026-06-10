{ baseHive, pkgs, ... }:

let stackHives = hives:
      let inherit (pkgs.lib) lists attrsets;

          optionalAttr = defaultValue: attrName: attrset:
            if attrsets.hasAttr attrName attrset
            then attrsets.getAttr attrName attrset
            else defaultValue;
          meta = lists.foldl attrsets.recursiveUpdate {} (map (optionalAttr ({}) "meta") hives);
          hostnames = (lists.remove "meta" (lists.unique (lists.concatMap builtins.attrNames hives)));

          mergeHostname = result: hostname:
            let imports = map (c: c.${hostname} or ({...}: {})) hives;
             in result // { ${hostname} = { ... }: { inherit imports; }; };

       in builtins.removeAttrs (lists.foldl mergeHostname { inherit meta; } hostnames) [ "override" "overrideDerivation" ];

    nodesFromHive = hive: builtins.attrNames (builtins.removeAttrs hive [ "meta" "defaults" ]);

    mkHive = hive: stackHives [ baseHive hive ];
in
{
  inherit stackHives nodesFromHive mkHive;
}
