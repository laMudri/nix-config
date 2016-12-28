{ mkDerivation, alex, array, base, binary, boxes, bytestring
, containers, cpphs, data-hash, deepseq, directory, EdisonCore
, edit-distance, emacs, equivalence, filepath, geniplate-mirror
, gitrev, happy, hashable, hashtables, haskeline, ieee754
, monadplus, mtl, murmur-hash, parallel, pretty, process
, regex-tdfa, stdenv, strict, template-haskell, text, time
, transformers, transformers-compat, unordered-containers, xhtml
, zlib
}:
mkDerivation {
  pname = "Agda";
  version = "2.5.2";
  sha256 = "0f8ld7sqkfhirhs886kp090iaq70qxsj8ms8farc80vzpz1ww4nq";
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    array base binary boxes bytestring containers data-hash deepseq
    directory EdisonCore edit-distance equivalence filepath
    geniplate-mirror gitrev hashable hashtables haskeline ieee754
    monadplus mtl murmur-hash parallel pretty process regex-tdfa strict
    template-haskell text time transformers transformers-compat
    unordered-containers xhtml zlib
  ];
  libraryToolDepends = [ alex cpphs happy ];
  executableHaskellDepends = [ base directory filepath process ];
  executableToolDepends = [ emacs ];
  postInstall = ''
    files=("$out/share/"*"-ghc-"*"/Agda-"*"/lib/prim/Agda/"{Primitive.agda,Builtin"/"*.agda})
    for f in "''${files[@]}" ; do
      $out/bin/agda $f
    done
    for f in "''${files[@]}" ; do
      $out/bin/agda -c --no-main $f
    done
    $out/bin/agda-mode compile
  '';
  homepage = "http://wiki.portal.chalmers.se/agda/";
  description = "A dependently typed functional programming language and proof assistant";
  license = "unknown";
}
