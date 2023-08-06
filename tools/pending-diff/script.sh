set -e

function listNodes {
  colmena eval -E "{ nodes, ... }: builtins.attrNames nodes" 2>/dev/null | jq .[] -r
}

function forNodes {
  readarray -t targets
  for target in "${targets[@]}"
  do
    forNode "$target"
  done
}

function forNode {
  local target="$1"
  echo "For node $target"
  remoteSystem="$(ssh "$target" readlink -f /nix/var/nix/profiles/system)"
  nix-copy-closure --from "$target" "$remoteSystem"
  nvd diff "$remoteSystem" "$(colmena eval -E "{ nodes, ... }: nodes.$target.config.system.build.toplevel" 2>/dev/null | jq . -r)"
}

if [[ $# -gt 0 ]]
then
  echo "For nodes $*"
  for target in "$@"
  do
    forNode "$target"
  done
else
  echo "All nodes"
  listNodes | forNodes
fi
