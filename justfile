# This message
help:
  just -l

code:
  $EDITOR flake.nix

# Build the tools
tools:
  nix build

# Test the hive and various home-manager configurations
test: test-hive test-home

# Test the hive configuration
test-hive:
  nix build .#integration-tests

# Test various home-manager configurations
test-home:
  # Test various home-manager configurations
  nix run home-manager/release-25.11 -- build --flake .#test-virtual-machine
  nix run home-manager/release-25.11 -- build --flake .#test-laptop-i3
  nix run home-manager/release-25.11 -- build --flake .#test-laptop-hyprland

# Lint the nix files
lint:
  nix run .#lint

# Like the CI would do
checks: lint tools test check-neovim-config

# Only checks the syntax
check-neovim-config:
  nix build .#neovim-config

# Integrations (not run by default locally)
integration-tests:
  nix build --print-build-logs .#integration-tests

update-extras:
  nix run .#obsidian-updater
