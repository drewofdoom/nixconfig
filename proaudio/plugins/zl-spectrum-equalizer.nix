# ZL Spectrum Equalizer. See zl-equalizer.nix for the pattern.
#
# NOTE: upstream has only prereleases (0.0.3 as of writing), so plain
# `nix-update zl-spectrum-equalizer --flake` will say "already up to date".
# Use `nix-update zl-spectrum-equalizer --flake --version=unstable` instead.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zl-spectrum-equalizer";
  version = "0.0.3";

  src = fetchzip {
    url = "https://github.com/ZL-Audio/ZLSpectrumEqualizer/releases/download/${finalAttrs.version}/ZL.Spectrum.Equalizer-${finalAttrs.version}-Linux-x86-64.zip";
    hash = "sha256-arkssF280iZ3NjE31Duf0ymieRyeNYDoHpiwYFkqnR4=";
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
    description = "ZL Spectrum Equalizer (spectrum-matching equalizer)";
    homepage = "https://github.com/ZL-Audio/ZLSpectrumEqualizer";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
