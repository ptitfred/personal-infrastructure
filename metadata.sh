colmena eval -E "{ lib, nodes, ... }: lib.attrsets.mapAttrs (_: value: value.config.deployment.tags) nodes" 2>/dev/null | yq -P
