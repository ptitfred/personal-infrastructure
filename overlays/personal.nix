self: super:

let fetchPackage = definition: path:
      self.callPackage (self.fetchFromGitHub (builtins.fromJSON (builtins.readFile definition)) + path) {};
in {
     posix-toolbox = fetchPackage ./ptitfred-posix-toolbox.json "/nix/default.nix";
     nix-linter = (fetchPackage ./synthetica9-nix-linter.json "/default.nix").nix-linter;
   }
