# DuskVerb (algorithmic reverb). See zl-equalizer.nix for the pattern.
# update-tag-prefix: duskverb
#
# Updates: release tags are prefixed (`duskverb-v<version>`), so use
# `nix-update duskverb --flake --version-regex 'duskverb-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "duskverb";
  version = "0.7.3";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/duskverb-v${finalAttrs.version}/duskverb-linux.zip";
    hash = "sha256-q4BvAH4RZtg1SS7DBZKz5eWrzKYL0wYmngjib9Cd/1E=";
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
    description = "DuskVerb (algorithmic reverb)";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
