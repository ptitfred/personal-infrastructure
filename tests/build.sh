#! /usr/bin/env nix-shell
# shellcheck shell=bash
#! nix-shell -i bash -p morph

set -e

HERE=$(dirname "$0")

morph build "$HERE/infra.nix"
