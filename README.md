# home-manager configuration

## Usage via Flakes

This project only support flakes.

Example flake.nix to use this project as a base (this is very close to what I do on my machines):

```nix
{
  description = "Private home-manager configuration";

  inputs.base.url = "github:ptitfred/home-manager";

  outputs = { base, ... }: {
    homeConfigurations.frederic = base.mkConfiguration ./local.nix;
  };
}
```
