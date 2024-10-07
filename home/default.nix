{ callPackage, pkgs, inputs, system, ... }:

let workstation =
      { ... }:
      {
        imports = [ ./workstation.nix ];
        nixpkgs.overlays = [
          inputs.ptitfred-posix-toolbox.overlay
          inputs.nil.overlays.nil
          inputs.wgsl-analyzer.overlays.default
          hm-overlay
        ];
      };

    hm-overlay = self: previous: {
      # 22.11 still available when needed
      previous = inputs.previous.legacyPackages.${system};

      haddocset = self.callPackage inputs.ptitfred-haddocset {};
      postgresql_12_postgis = self.postgresql_12.withPackages (p: [ p.postgis ]);
      inherit (pkgs) nix-linter;
      inherit (inputs.spago2nix.packages.${system}) spago2nix;
      easy-ps = inputs.easy-purescript-nix.packages.${system};
      tmuxPlugins = previous.tmuxPlugins // {
        power-theme = previous.tmuxPlugins.power-theme.overrideAttrs (_: { src = inputs.power-theme; });
      };
    };

    mkHomeConfiguration = module:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ workstation module ];
      };
in
  {
    inherit workstation mkHomeConfiguration;
    tools = callPackage ./tools.nix {};
  }
