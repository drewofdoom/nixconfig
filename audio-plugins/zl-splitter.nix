# ZL Splitter (multiband splitter). See zl-equalizer.nix for the pattern.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zl-splitter";
  version = "0.3.0";

  src = fetchzip {
    url = "https://github.com/ZL-Audio/ZLSplitter/releases/download/${finalAttrs.version}/ZL.Splitter-${finalAttrs.version}-Linux-x86.zip";
    hash = "sha256-apQaKu0mhg4GjPHPwFzCltLna6EXaZJ+vYOEx6vdsNc=";
    # Asset unpacks flat (LV2/ VST3/ at root, no wrapper dir).
    stripRoot = false;
  };

  # This release ships LV2 + VST3 bundles (no standalone, no CLAP).
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lv2 $out/vst3
    cp -r "$src/LV2/"*.lv2 $out/lv2/
    cp -r "$src/VST3/"*.vst3 $out/vst3/
    runHook postInstall
  '';

  passthru.formats = [
    "lv2"
    "vst3"
  ];

  meta = {
    description = "ZL Splitter (multiband frequency splitter)";
    homepage = "https://github.com/ZL-Audio/ZLSplitter";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
