#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p nix-linter

set -e

find . -type f -name "*.nix" -exec nix-linter {} \;
