# Dusk Tape Echo 2. See zl-equalizer.nix for the pattern.
# update-tag-prefix: tape-echo-2
#
# Updates: release tags are prefixed (`tape-echo-2-v<version>`), so use
# `nix-update dusk-tape-echo-2 --flake --version-regex 'tape-echo-2-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-tape-echo-2";
  version = "1.0.7";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/tape-echo-2-v${finalAttrs.version}/tape-echo-2-linux.zip";
    hash = "sha256-AxcOvdeu+aTel8HMkr9ZL0OXDrat6hK5UD3xmZmb1A0=";
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
    description = "Dusk Tape Echo 2";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
