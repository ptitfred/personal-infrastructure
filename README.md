# system and home-manager configuration

## Usage via Flakes

This project only support flakes.

Example flake.nix to use this project as a base (this is very close to what I do on my machines):

```nix
{
  description = "Private infra & home-manager configuration";

  inputs.infra.url = "github:ptitfred/personal-infrastructure";

  outputs = { infra, ... }: {
    homeConfigurations.frederic = infra.lib.mkHomeConfiguration ./local.nix;
  };
}
```
