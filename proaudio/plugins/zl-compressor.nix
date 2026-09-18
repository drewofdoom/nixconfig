# ZL Compressor. See zl-equalizer.nix for the pattern.
#
# NOTE: upstream also publishes a plain x86-64 zip; we take -AVX2
# (both machines support it).
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zl-compressor";
  version = "0.6.0";

  src = fetchzip {
    url = "https://github.com/ZL-Audio/ZLCompressor/releases/download/${finalAttrs.version}/ZL.Compressor-${finalAttrs.version}-Linux-x86-64-AVX2.zip";
    hash = "sha256-d8uSJ/J6bPPH7Jt6sUnbhhdiA/8tqC9elf2iqleSt4U=";
    # Asset unpacks flat (LV2/ Standalone/ VST3/ at root, no wrapper dir).
    stripRoot = false;
  };

  # This release ships LV2 + VST3 bundles and a standalone binary (no CLAP).
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lv2 $out/vst3 $out/bin
    cp -r "$src/LV2/"*.lv2 $out/lv2/
    cp -r "$src/VST3/"*.vst3 $out/vst3/
    cp "$src/Standalone/"* $out/bin/
    runHook postInstall
  '';

  passthru.formats = [
    "lv2"
    "vst3"
  ];

  meta = {
    description = "ZL Compressor";
    homepage = "https://github.com/ZL-Audio/ZLCompressor";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
