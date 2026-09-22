# Dusk 4K EQ 2. See zl-equalizer.nix for the pattern.
# update-tag-prefix: 4k-eq-2
#
# Updates: release tags are prefixed (`4k-eq-2-v<version>`), so use
# `nix-update dusk-4k-eq-2 --flake --version-regex '4k-eq-2-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-4k-eq-2";
  version = "1.0.5";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/4k-eq-2-v${finalAttrs.version}/4k-eq-2-linux.zip";
    hash = "sha256-i+hJfmX7f/qEGzs/9krP2jeNDU4GhUqsMqn1jmY1jcI=";
    # Asset has a single top-level wrapper dir (default stripRoot).
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/clap
    cp "$src/CLAP/"*.clap $out/lib/clap/
    mkdir -p $out/lib/lv2
    cp -r "$src/LV2/"*.lv2 $out/lib/lv2/
    mkdir -p $out/lib/vst3
    cp -r "$src/VST3/"*.vst3 $out/lib/vst3/
    runHook postInstall
  '';

  passthru.formats = [
    "clap"
    "lv2"
    "vst3"
  ];

  meta = {
    description = "Dusk 4K EQ 2";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
