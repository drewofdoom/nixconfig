# Dusk MultiQ (parametric equalizer). See zl-equalizer.nix for the pattern.
# update-tag-prefix: multi-q
#
# Updates: release tags are prefixed (`multi-q-v<version>`), so use
# `nix-update dusk-multi-q --flake --version-regex 'multi-q-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-multi-q";
  version = "0.10.9";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/multi-q-v${finalAttrs.version}/multi-q-linux.zip";
    hash = "sha256-mzh2wFmROP3ukYny2rAx5/weQsdnuRJdUPx+Tm694AE=";
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
    description = "Dusk MultiQ (parametric equalizer)";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
