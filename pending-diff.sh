#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p morph nvd

nvd diff "$(ssh "$1" readlink -f /nix/var/nix/profiles/system)" "$(morph build --on="$1" ./test-infra.nix)/$1"
