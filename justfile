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
  # Test the hive configuration
  nix build .#tests

# Test various home-manager configurations
test-home:
  # Test various home-manager configurations
  nix run home-manager/release-24.11 -- build --flake .#test-virtual-machine
  nix run home-manager/release-24.11 -- build --flake .#test-laptop

# Lint the nix files
lint:
  nix run .#lint

# Like the CI would do
checks: lint tools test

# Integrations (not run by default locally)
integration-tests:
  nix build --print-build-logs .#integration-tests

update-extras:
  nix run .#lix-updater
  nix run .#obsidian-updater
  nix run .#matomo-updater
