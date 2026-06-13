{ inputs, callPackage, lib, strings, linkFarm, lua, runCommand }:

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

    compile-lua-file = path: "luac ${path};";
    lua-files = homeConfigurations.test-laptop.config.programs.neovim.extraLuaConfigFiles;

    neovim-config = runCommand "neovim-lua-check" { buildInputs = [ lua ]; } ''
      mkdir -p $out
      ${strings.concatMapStrings compile-lua-file lua-files}
    '';

in { inherit homeConfigurations integration-tests tests test-hive neovim-config; }
