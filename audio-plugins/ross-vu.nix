# ROSS VU (analog-style energy meter). See zl-equalizer.nix for the pattern.
#
# Single-asset bundle (CLAP + LV2 + VST3 + standalone in one tarball).
# Tags are v-prefixed; if `nix-update ross-vu --flake` misreads the version,
# retry with `--version-regex 'v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ross-vu";
  version = "1.4.1";

  src = fetchzip {
    url = "https://github.com/RickRossati/ross-vu/releases/download/v${finalAttrs.version}/ROSS-VU-${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-3RLlMNseICLFDnePfHU645cpIngouw1EktnEc8TfFiY=";
    # Asset has a single top-level wrapper dir (default stripRoot).
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/clap $out/lv2 $out/vst3 $out/bin
    cp "$src/"*.clap $out/clap/
    cp -r "$src/"*.lv2 $out/lv2/
    cp -r "$src/"*.vst3 $out/vst3/
    cp "$src/ROSSVU" $out/bin/
    runHook postInstall
  '';

  passthru.formats = [
    "clap"
    "lv2"
    "vst3"
  ];

  meta = {
    description = "ROSS VU (analog energy meter)";
    homepage = "https://github.com/RickRossati/ross-vu";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
