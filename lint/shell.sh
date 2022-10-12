#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p shellcheck

set -e

here=$(dirname "$0")
root="$here/.."

find "$root" -type f -name "*.sh" -exec shellcheck {} + && echo "Everything is fine!"
