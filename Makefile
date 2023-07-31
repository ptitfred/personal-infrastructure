.PHONY:
test:
	nix build .#tests

.PHONY:
lint:
	nix run .#lint

.PHONY:
checks: lint test
