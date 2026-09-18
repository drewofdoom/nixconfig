# Loopino (looper). See zl-equalizer.nix for the pattern.
#
# Brummer10 ships one asset per format, so this uses `srcs` + an
# extension-sorting installPhase instead of a single bundle copy.
# Tags are v-prefixed; if `nix-update brummer-loopino --flake` misreads the
# version, retry with `--version-regex 'v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brummer-loopino";
  version = "0.9.6";

  srcs = [
    (fetchzip {
      name = "loopino-clap";
      url = "https://github.com/brummer10/Loopino/releases/download/v${finalAttrs.version}/Loopino-clap-v${finalAttrs.version}-linux-x86_64.tar.xz";
      hash = "sha256-HZcP0fCUMw1G/ptatEoLTw7U/11BlRQQ796bswXj/Kc=";
    })
    (fetchzip {
      name = "loopino-vst2";
      url = "https://github.com/brummer10/Loopino/releases/download/v${finalAttrs.version}/Loopino-vst2-v${finalAttrs.version}-linux-x86_64.tar.xz";
      hash = "sha256-KnYwRwBGPx8mjCS5QkczUFP6yjApWIa+fGzAMCY6kTk=";
    })
    (fetchzip {
      name = "loopino-app";
      url = "https://github.com/brummer10/Loopino/releases/download/v${finalAttrs.version}/Loopino-app-v${finalAttrs.version}-linux-x86_64.tar.xz";
      hash = "sha256-FmgCAFMbUsRvnzcLlKBqN+6+OmvCrQSKfB4GO6LQB7A=";
    })
  ];

  dontUnpack = true;

  # Each fetchzip output is already unpacked (single file or bundle);
  # merge them into work/ and sort by extension below.
  installPhase = ''
    runHook preInstall
    mkdir -p work
    for a in $srcs; do cp -r "$a/"* work/; done
    mkdir -p $out/clap $out/vst2 $out/bin
    for f in work/*; do
      case "$f" in
        *.clap) cp "$f" $out/clap/ ;;
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
    "vst2"
  ];

  meta = {
    description = "Loopino (looper)";
    homepage = "https://github.com/brummer10/Loopino";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
