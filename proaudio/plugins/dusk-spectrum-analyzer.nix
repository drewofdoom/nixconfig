# Dusk Spectrum Analyzer. See zl-equalizer.nix for the pattern.
# update-tag-prefix: spectrum-analyzer
#
# Updates: release tags are prefixed (`spectrum-analyzer-v<version>`), so use
# `nix-update dusk-spectrum-analyzer --flake --version-regex 'spectrum-analyzer-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-spectrum-analyzer";
  version = "1.0.2";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/spectrum-analyzer-v${finalAttrs.version}/spectrum-analyzer-linux.zip";
    hash = "sha256-B658Dl1pe+ZzZSYbUiDhrzosF68hgP8Wik+a9awG16Q=";
    # Asset unpacks flat (format dirs at root, no wrapper dir).
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/lv2
    cp -r "$src/LV2/"*.lv2 $out/lib/lv2/
    mkdir -p $out/lib/vst3
    cp -r "$src/VST3/"*.vst3 $out/lib/vst3/
    runHook postInstall
  '';

  passthru.formats = [
    "lv2"
    "vst3"
  ];

  meta = {
    description = "Dusk Spectrum Analyzer";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
