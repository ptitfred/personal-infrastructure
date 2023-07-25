{ pkgs, ... }:

let stackHives = hives:
      let inherit (pkgs.lib) lists attrsets;

          meta = lists.foldl attrsets.recursiveUpdate {} (map (c: c.meta) hives);
          hostnames = lists.remove "meta" (lists.unique (lists.concatMap builtins.attrNames hives));

          mergeHostname = result: hostname:
            let imports = map (c: c.${hostname} or ({...}: {})) hives;
             in result // { ${hostname} = { ... }: { inherit imports; }; };

       in builtins.removeAttrs (lists.foldl mergeHostname { inherit meta; } hostnames) [ "override" "overrideDerivation" ];

    nodesFromHive = hive: builtins.attrNames (builtins.removeAttrs hive [ "meta" ]);
in
{
  inherit stackHives nodesFromHive;
}
