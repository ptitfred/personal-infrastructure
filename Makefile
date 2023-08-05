.PHONY:
test:
	nix run home-manager/release-23.05 -- build --flake .#test
	nix run home-manager/release-23.05 -- build --flake .#test-laptop

.PHONY:
lint:
	nix run .#lint
