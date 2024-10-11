# system and home-manager configuration

Currently based on nixos-24.05 and home-manager-24.05 (both must be consistent).

## Usage via Flakes

This project only support flakes.

Example flake.nix to use this project as a base (this is very close to what I do on my machines):

```nix
{
  description = "Private infra & home-manager configuration";

  inputs.infra.url = "github:ptitfred/personal-infrastructure";

  outputs = { infra, ... }: {
    # Declare home-manager configurations (user)
    # See home-manager documentation how to declare a configuration:
    # <https://nix-community.github.io/home-manager/index.xhtml#sec-usage-configuration>
    # You can declare multiple home configurations and later use one with:
    # $ nix run home-manager/release-24.05 -- build --flake .#frederic
    homeConfigurations.frederic = infra.lib.mkHomeConfiguration ./home-frederic.nix;

    # Declare colmena configurations (system).
    # See colmena documentation how to declare a set of hosts:
    # <https://colmena.cli.rs/unstable/tutorial/index.html#basic-configuration>
    colmena = infra.lib.mkHive (import ./system.nix);
  };
}
```
