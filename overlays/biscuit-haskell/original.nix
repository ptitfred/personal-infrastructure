{ mkDerivation, aeson, async, attoparsec, base, base16-bytestring
, base64, bytestring, cereal, containers, criterion, cryptonite
, fetchzip, lens, lens-aeson, lib, memory, mtl, parser-combinators
, protobuf, random, regex-tdfa, tasty, tasty-hunit
, template-haskell, text, th-lift-instances, time
, validation-selective
}:
mkDerivation {
  pname = "biscuit-haskell";
  version = "0.2.1.0";
  src = fetchzip {
    url = "https://frederic.menou.me/biscuit-haskell-original.tar.gz";
    sha256 = "18p8xx81j9bw2hs4ry04x5c52r1vdxv6agd2zj8y00kcszalgn2s";
  };
  libraryHaskellDepends = [
    async attoparsec base base16-bytestring base64 bytestring cereal
    containers cryptonite memory mtl parser-combinators protobuf random
    regex-tdfa template-haskell text th-lift-instances time
    validation-selective
  ];
  testHaskellDepends = [
    aeson async attoparsec base base16-bytestring base64 bytestring
    cereal containers cryptonite lens lens-aeson mtl parser-combinators
    protobuf random tasty tasty-hunit template-haskell text
    th-lift-instances time validation-selective
  ];
  benchmarkHaskellDepends = [ base criterion ];
  homepage = "https://github.com/biscuit-auth/biscuit-haskell#readme";
  description = "Library support for the Biscuit security token";
  license = lib.licenses.bsd3;
}
