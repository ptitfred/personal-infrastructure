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
    url = "https://frederic.menou.me/biscuit-haskell-0.2.1.0.tar.gz";
    sha256 = "0izh7bmg5zr2j8vp0clzyd2bgc41zq54i3scl3cjvimx74fh3lq0";
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
