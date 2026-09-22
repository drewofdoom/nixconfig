# Dusk Chord Analyzer. See zl-equalizer.nix for the pattern.
# update-tag-prefix: chord-analyzer
#
# Updates: release tags are prefixed (`chord-analyzer-v<version>`), so use
# `nix-update dusk-chord-analyzer --flake --version-regex 'chord-analyzer-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-chord-analyzer";
  version = "1.3.0";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/chord-analyzer-v${finalAttrs.version}/chord-analyzer-linux.zip";
    hash = "sha256-mZTloVb0J/kBW+cXqJ0Gefi9pg9+EQDNaEwY0mcBi88=";
    # Asset unpacks flat (format dirs at root, no wrapper dir).
    stripRoot = false;
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
    description = "Dusk Chord Analyzer";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
