# home-manager configuration

## Usage via Flakes

This project only support flakes.

Example flake.nix to use this project as a base (this is very close to what I do on my machines):

```nix
{
  description = "Private home-manager configuration";

  inputs.base.url = "github:ptitfred/nixos-configuration/flakes";

  outputs = { base, ... }: {
    homeConfigurations.frederic = base.homeConfigurationHelper {
      modules = [
        # This local.nix file is where you can customise this base configuration and extend it with your own home-manager options
        ./local.nix
      ];
    };
  };
}
```
