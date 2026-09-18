# LoadBox (cabinet loader). See brummer-loopino.nix for the multi-asset
# pattern (one asset per format, sorted by extension).
#
# Tags are v-prefixed; if `nix-update brummer-loadbox --flake` misreads the
# version, retry with `--version-regex 'v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brummer-loadbox";
  version = "0.1.0";

  srcs = [
    (fetchzip {
      name = "loadbox-clap";
      url = "https://github.com/brummer10/LoadBox/releases/download/v${finalAttrs.version}/LoadBox-v${finalAttrs.version}-clap-linux-x86_64.tar.xz";
      hash = "sha256-m96toAGJHtKsEXTPVmOF6+WaRRrHyDrOAq+zCSbT23A=";
    })
    (fetchzip {
      name = "loadbox-vst2";
      url = "https://github.com/brummer10/LoadBox/releases/download/v${finalAttrs.version}/LoadBox-v${finalAttrs.version}-vst2-linux-x86_64.tar.xz";
      hash = "sha256-UDA1W+hKywEBwtD+lnV8wJ12MKpyYDRyDcqh8jIoAn4=";
    })
    (fetchzip {
      name = "loadbox-vst3";
      url = "https://github.com/brummer10/LoadBox/releases/download/v${finalAttrs.version}/LoadBox-v${finalAttrs.version}-vst3-linux-x86_64.tar.xz";
      hash = "sha256-oEMusUb3Q1hb6z4YyHKDQoHquUkbTktLJiQTKRH58cM=";
    })
  ];

  dontUnpack = true;

  # Each fetchzip output is already unpacked (single file or bundle);
  # merge them into work/ and sort by extension below.
  installPhase = ''
    runHook preInstall
    mkdir -p work
    for a in $srcs; do cp -r "$a/"* work/; done
    mkdir -p $out/clap $out/vst2 $out/vst3
    for f in work/*; do
      case "$f" in
        *.clap) cp "$f" $out/clap/ ;;
        *.vst3) cp -r "$f" $out/vst3/ ;;
        *.so) cp "$f" $out/vst2/ ;;
      esac
    done
    runHook postInstall
  '';

  passthru.formats = [
    "clap"
    "vst2"
    "vst3"
  ];

  meta = {
    description = "LoadBox (cabinet loader)";
    homepage = "https://github.com/brummer10/LoadBox";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
