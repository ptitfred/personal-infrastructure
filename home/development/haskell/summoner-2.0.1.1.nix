{ mkDerivation, base, colourista, directory, fetchgit, filepath
, generic-data, gitrev, hedgehog, hspec, hspec-hedgehog, lib
, microaeson, optparse-applicative, process, relude, shellmet, time
, tomland, tree-diff, validation-selective
}:
mkDerivation {
  pname = "summoner";
  version = "2.0.1.1";
  src = fetchgit {
    url = "https://github.com/kowainik/summoner";
    sha256 = "0fkhq7bs351w9qa3n01736lpgsqlgsnfqcb5spw5jk226v02yhzr";
    rev = "30b56041a501341dd0db41fe83a9cc161fc9552f";
    fetchSubmodules = true;
  };
  postUnpack = "sourceRoot+=/summoner-cli; echo source root reset to $sourceRoot";
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base colourista directory filepath generic-data gitrev microaeson
    optparse-applicative process relude shellmet time tomland
    validation-selective
  ];
  executableHaskellDepends = [ base relude ];
  testHaskellDepends = [
    base directory filepath hedgehog hspec hspec-hedgehog relude
    tomland tree-diff validation-selective
  ];
  homepage = "https://github.com/kowainik/summoner";
  description = "Tool for scaffolding fully configured batteries-included production-level Haskell projects";
  license = lib.licenses.mpl20;
}
