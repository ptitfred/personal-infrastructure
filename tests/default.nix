{ inputs, callPackage, lib, linkFarm, lua, runCommand }:

let test-hive = import ./infra.nix;
    test-infra = (lib.mkHive test-hive).toplevel;

    tests =
      let mkNode = name: { inherit name; path = test-infra.${name}; };
          nodes = lib.nodesFromHive test-hive;
       in linkFarm test-hive.meta.description (map mkNode nodes);

    homeConfigurations = {
      test-virtual-machine = lib.mkHomeConfiguration ./virtual-machine.nix;
      test-laptop          = lib.mkHomeConfiguration ./laptop.nix;
    };

    integration-tests = callPackage ./integration-tests.nix {
      inherit inputs;
      cores = 2;
      memorySize = 4096;
    };

    neovim-config = runCommand "neovim-lua-check" { buildInputs = [ lua ]; } ''
      mkdir -p $out
      luac ${../home/development/neovim-config.lua}
    '';

in { inherit homeConfigurations integration-tests tests test-hive neovim-config; }
