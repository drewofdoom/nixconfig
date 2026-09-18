# Dusk MultiComp (multiband compressor). See zl-equalizer.nix for the pattern.
# update-tag-prefix: multi-comp
#
# Updates: release tags are prefixed (`multi-comp-v<version>`), so use
# `nix-update dusk-multi-comp --flake --version-regex 'multi-comp-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-multi-comp";
  version = "1.3.8";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/multi-comp-v${finalAttrs.version}/multi-comp-linux.zip";
    hash = "sha256-mAckn4i/uuy/ss8irari0BrDVIARib6KnaL2nH2Dfw4=";
    # Asset unpacks flat (format dirs at root, no wrapper dir).
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/clap
    cp "$src/CLAP/"*.clap $out/clap/
    mkdir -p $out/lv2
    cp -r "$src/LV2/"*.lv2 $out/lv2/
    mkdir -p $out/vst3
    cp -r "$src/VST3/"*.vst3 $out/vst3/
    runHook postInstall
  '';

  passthru.formats = [
    "clap"
    "lv2"
    "vst3"
  ];

  meta = {
    description = "Dusk MultiComp (multiband compressor)";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
