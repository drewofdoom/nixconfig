# NeuralRack (neural amp modeler). See brummer-loopino.nix for the
# multi-asset pattern (one asset per format, sorted by extension).
#
# NOTE: upstream also ships a `NeuralRack-v3-lv2-*` asset (v3 engine LV2)
# under the same bundle name, so only one LV2 can be installed. We take the
# default LV2 from the main asset; swap the lv2 URL for the v3 one to try it.
#
# Tags are v-prefixed; if `nix-update brummer-neuralrack --flake` misreads
# the version, retry with `--version-regex 'v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brummer-neuralrack";
  version = "0.4.1";

  srcs = [
    (fetchzip {
      name = "neuralrack-clap";
      url = "https://github.com/brummer10/NeuralRack/releases/download/v${finalAttrs.version}/NeuralRack-v${finalAttrs.version}-clap-linux-x86_64.tar.xz";
      hash = "sha256-8wHSkaKFKPaWnSpRcN/q60Yt1IKefLazvKGYDjoQaMM=";
    })
    (fetchzip {
      name = "neuralrack-lv2";
      url = "https://github.com/brummer10/NeuralRack/releases/download/v${finalAttrs.version}/NeuralRack-v${finalAttrs.version}-linux-x86_64.tar.xz";
      hash = "sha256-KVIuBqAZYcZctIEqA9p/osZdNwLQCcuv4cY3UxUiPKM=";
    })
    (fetchzip {
      name = "neuralrack-vst2";
      url = "https://github.com/brummer10/NeuralRack/releases/download/v${finalAttrs.version}/NeuralRack-v${finalAttrs.version}-vst2-linux-x86_64.tar.xz";
      hash = "sha256-ZubFANDk6lTgIef+NSHxOyCarPqY5RxQqQAclB9YEFM=";
    })
    (fetchzip {
      name = "neuralrack-vst3";
      url = "https://github.com/brummer10/NeuralRack/releases/download/v${finalAttrs.version}/NeuralRack-v${finalAttrs.version}-vst3-linux-x86_64.tar.xz";
      hash = "sha256-SIkEE+LbldOa+yOor+8OsugThSePwS9Ki2F7phCwvIU=";
    })
    (fetchzip {
      name = "neuralrack-app";
      url = "https://github.com/brummer10/NeuralRack/releases/download/v${finalAttrs.version}/NeuralRack-app-v${finalAttrs.version}-linux-x86_64.tar.xz";
      hash = "sha256-Y75mQmkurrnogQKB8nRbUUpofkuRGRxZPJ7UfBK1tWI=";
    })
  ];

  dontUnpack = true;

  # Each fetchzip output is already unpacked (single file or bundle);
  # merge them into work/ and sort by extension below.
  installPhase = ''
    runHook preInstall
    mkdir -p work
    for a in $srcs; do cp -r "$a/"* work/; done
    mkdir -p $out/clap $out/lv2 $out/vst2 $out/vst3 $out/bin
    for f in work/*; do
      case "$f" in
        *.clap) cp "$f" $out/clap/ ;;
        *.lv2) cp -r "$f" $out/lv2/ ;;
        *.vst3) cp -r "$f" $out/vst3/ ;;
        *.so) cp "$f" $out/vst2/ ;;
        *)
          if [ -f "$f" ] && [ -x "$f" ]; then cp "$f" $out/bin/; fi
          ;;
      esac
    done
    runHook postInstall
  '';

  passthru.formats = [
    "clap"
    "lv2"
    "vst2"
    "vst3"
  ];

  meta = {
    description = "NeuralRack (neural amp modeler)";
    homepage = "https://github.com/brummer10/NeuralRack";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
