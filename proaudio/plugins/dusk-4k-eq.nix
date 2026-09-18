# Dusk 4K EQ. See zl-equalizer.nix for the pattern.
# update-tag-prefix: 4k-eq
#
# Updates: release tags are prefixed (`4k-eq-v<version>`), so use
# `nix-update dusk-4k-eq --flake --version-regex '4k-eq-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-4k-eq";
  version = "1.0.12";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/4k-eq-v${finalAttrs.version}/4k-eq-linux.zip";
    hash = "sha256-cb69iveWAYpLoRGWaEw+bfiYv6r9bNCRjzjCA7mQdoQ=";
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
    description = "Dusk 4K EQ";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
