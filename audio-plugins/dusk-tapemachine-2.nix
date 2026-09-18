# Dusk TapeMachine 2. See zl-equalizer.nix for the pattern.
# update-tag-prefix: tapemachine-2
#
# Updates: release tags are prefixed (`tapemachine-2-v<version>`), so use
# `nix-update dusk-tapemachine-2 --flake --version-regex 'tapemachine-2-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-tapemachine-2";
  version = "1.0.11";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/tapemachine-2-v${finalAttrs.version}/tapemachine-2-linux.zip";
    hash = "sha256-w7d2vuntlYsjyb2KuEPX6e3zP5xD7AxhZqNIdzBCNEc=";
    # Asset has a single top-level wrapper dir (default stripRoot).
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
    description = "Dusk TapeMachine 2";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
