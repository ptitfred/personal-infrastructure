#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p nix-linter

set -e

here=$(dirname "$0")
root="$here/.."

find "$root" -type f -name "*.nix" ! -path "$root/nix/*" -exec nix-linter {} + && echo "Everything is fine!"
