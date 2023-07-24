#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p morph nvd

remoteSystem="$(ssh "$1" readlink -f /nix/var/nix/profiles/system)"
nix-copy-closure --from "$1" "$remoteSystem"
nvd diff "$remoteSystem" "$(morph build --on="$1" ./test-infra.nix)/$1"
