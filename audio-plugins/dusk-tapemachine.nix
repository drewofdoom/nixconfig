# Dusk TapeMachine. See zl-equalizer.nix for the pattern.
# update-tag-prefix: tapemachine
#
# Updates: release tags are prefixed (`tapemachine-v<version>`), so use
# `nix-update dusk-tapemachine --flake --version-regex 'tapemachine-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-tapemachine";
  version = "1.0.10";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/tapemachine-v${finalAttrs.version}/tapemachine-linux.zip";
    hash = "sha256-Y8JyuGRY1GYlfi2b0ivQShPtAWM6S7TrEuhCNHnEvc4=";
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
    description = "Dusk TapeMachine";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
