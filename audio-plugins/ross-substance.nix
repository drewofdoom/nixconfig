# SUBSTANCE (hybrid bass engine, free build). See zl-equalizer.nix for
# the pattern.
#
# Proprietary freeware (paid Pro tier exists), so meta.license is unfree and
# the flake instantiates this one with allowUnfree (see flake.nix).
# NOTE: the asset filename is UNVERSIONED, so a version bump alone changes no
# URL -- update.py refetches the hash anyway (it refetches all hashes whenever
# the version changes, even with no URL drift).
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ross-substance";
  version = "1.0.1";

  src = fetchzip {
    url = "https://github.com/RickRossati/substance/releases/download/v${finalAttrs.version}/SUBSTANCE-Linux-x86_64.tar.gz";
    hash = "sha256-Sbxj/AOQTq0f/+pkxFqxS1N6YtQnHMj5MlppW35YQK8=";
    # Asset has a single top-level wrapper dir (default stripRoot).
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/vst3 $out/bin
    cp -r "$src/"*.vst3 $out/vst3/
    cp "$src/SUBSTANCE" $out/bin/
    runHook postInstall
  '';

  passthru.formats = [ "vst3" ];

  meta = {
    description = "SUBSTANCE (hybrid bass engine, free build)";
    homepage = "https://github.com/RickRossati/substance";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
