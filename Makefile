.PHONY:
test:
	nix run home-manager/release-23.05 -- build --flake .#test

.PHONY:
lint:
	nix run .#lint
