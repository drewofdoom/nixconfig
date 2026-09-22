# Template for GitHub-release audio plugins.
#
# To add a plugin: copy this file, adjust pname/version/url/asset name,
# installPhase copies, and passthru.formats, add one line to the `packages`
# output in flake.nix, and `proaudio/plugins/default.nix` symlinks it into
# ~/.clap ~/.vst3 ~/.lv2 ~/.vst ~/.ladspa automatically.
#
# Updates: `nix-update <pname> --flake` from the repo root (tracks the
# latest GitHub release, bumps version + hash). If upstream adds a new
# format (e.g. CLAP), add it to installPhase AND passthru.formats by hand.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zl-equalizer";
  version = "1.3.1";

  src = fetchzip {
    url = "https://github.com/ZL-Audio/ZLEqualizer/releases/download/${finalAttrs.version}/ZL.Equalizer.2-${finalAttrs.version}-Linux-x86-64.zip";
    hash = "sha256-Gu00HOHP3CkfVTN0PZ9dzwGAj7jvsKL4ERaxdeNy2vo=";
    # Asset unpacks flat (LV2/ Standalone/ VST3/ at root, no wrapper dir).
    stripRoot = false;
  };

  # This release ships LV2 + VST3 bundles and a standalone binary (no CLAP).
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/lv2 $out/lib/vst3 $out/bin
    cp -r "$src/LV2/"*.lv2 $out/lib/lv2/
    cp -r "$src/VST3/"*.vst3 $out/lib/vst3/
    cp "$src/Standalone/"* $out/bin/
    runHook postInstall
  '';

  # Formats this derivation installs to $out/<format>. Must match
  # installPhase; proaudio/plugins/default.nix symlinks each one into the
  # corresponding ~/ search dir. Subset of: clap vst3 vst2 lv2 ladspa.
  passthru.formats = [
    "lv2"
    "vst3"
  ];

  meta = {
    description = "ZL Equalizer 2 (EZIIEQ-style equalizer)";
    homepage = "https://github.com/ZL-Audio/ZLEqualizer";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
