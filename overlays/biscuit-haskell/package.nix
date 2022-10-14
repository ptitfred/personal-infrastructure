{ mkDerivation, aeson, async, attoparsec, base, base16-bytestring
, base64, bytestring, cereal, containers, criterion, cryptonite
, directory, fetchzip, filepath, lens, lens-aeson, lib, memory, mtl
, parser-combinators, protobuf, random, regex-tdfa, tasty
, tasty-hunit, template-haskell, text, th-lift-instances, time
, validation-selective
}:
mkDerivation {
  pname = "biscuit-haskell";
  version = "0.2.1.0";
  src = fetchzip {
    url = "https://github.com/ptitfred/biscuit-haskell/archive/refs/heads/fix-nixpkgs.zip";
    sha256 = "k+som/AG1U2YNRF/CauDZPd9ufPwwrWOgjCHRZTo98I="; # "1hppx2a4b1rhha7bbhphyfwpvxv4hfmhjzqi6nc4vm86y2djiswk";
  };
  postUnpack = "sourceRoot+=/biscuit; echo source root reset to $sourceRoot";
  enableSeparateDataOutput = true;
  libraryHaskellDepends = [
    async attoparsec base base16-bytestring base64 bytestring cereal
    containers cryptonite memory mtl parser-combinators protobuf random
    regex-tdfa template-haskell text th-lift-instances time
    validation-selective
  ];
  testHaskellDepends = [
    aeson async attoparsec base base16-bytestring base64 bytestring
    cereal containers cryptonite directory filepath lens lens-aeson mtl
    parser-combinators protobuf random tasty tasty-hunit
    template-haskell text th-lift-instances time validation-selective
  ];
  benchmarkHaskellDepends = [ base criterion ];
  homepage = "https://github.com/biscuit-auth/biscuit-haskell#readme";
  description = "Library support for the Biscuit security token";
  license = lib.licenses.bsd3;
}
