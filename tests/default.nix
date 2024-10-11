{ inputs, lib, linkFarm }:

let test-hive = lib.mkHive (import ./infra.nix);
    test-infra = (inputs.colmena.lib.makeHive test-hive).toplevel;

    tests =
      let mkNode = name: { inherit name; path = test-infra.${name}; };
          nodes = lib.nodesFromHive test-hive;
       in linkFarm test-hive.meta.description (map mkNode nodes);

    homeConfigurations = {
      test-virtual-machine = lib.mkHomeConfiguration ./virtual-machine.nix;
      test-laptop          = lib.mkHomeConfiguration ./laptop.nix;
    };

in { inherit homeConfigurations tests test-hive; }
