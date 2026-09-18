# Dusk Sunset Circuits. See zl-equalizer.nix for the pattern.
# update-tag-prefix: sunset-circuits
#
# Updates: release tags are prefixed (`sunset-circuits-v<version>`), so use
# `nix-update dusk-sunset-circuits --flake --version-regex 'sunset-circuits-v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dusk-sunset-circuits";
  version = "1.0.7";

  src = fetchzip {
    url = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/sunset-circuits-v${finalAttrs.version}/sunset-circuits-linux.zip";
    hash = "sha256-e+sZInObFDbwrrcOrHOBtLck68EPPXK7e2h6dGFIn/c=";
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
    description = "Dusk Sunset Circuits";
    homepage = "https://github.com/dusk-audio/dusk-audio-plugins";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
