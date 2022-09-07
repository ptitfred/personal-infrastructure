let fetchDep = self: file:
      import
        (self.fetchFromGitHub (builtins.fromJSON (builtins.readFile file))) { };
in
  self: {...}:
    {
      spago2nix = fetchDep self ./spago2nix.json;
      easy-ps   = fetchDep self ./easy-ps.json;
    }
