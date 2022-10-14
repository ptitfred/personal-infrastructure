self: super:
  {
    haskell = super.haskell // {
      packages = super.haskell.packages // {
        ghc902 = super.haskell.packages.ghc902.override {
          overrides = self: super: {
            biscuit-haskell = self.callPackage biscuit-haskell/package.nix {};
            biscuit-haskell-candidate = self.callPackage biscuit-haskell/candidate.nix {};
            biscuit-haskell-original  = self.callPackage biscuit-haskell/original.nix  {};
          };
        };
      };
    };
  }
