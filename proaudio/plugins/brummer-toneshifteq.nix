# ToneShiftEQ (parametric equalizer). See brummer-loopino.nix for the
# multi-asset pattern (one asset per format, sorted by extension).
#
# Tags are v-prefixed; if `nix-update brummer-toneshifteq --flake` misreads
# the version, retry with `--version-regex 'v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brummer-toneshifteq";
  version = "1.1.0";

  srcs = [
    (fetchzip {
      name = "toneshifteq-clap";
      url = "https://github.com/brummer10/ToneShiftEQ/releases/download/v${finalAttrs.version}/ToneShiftEQ-v${finalAttrs.version}-clap-linux-x86_64.tar.xz";
      hash = "sha256-HdWUKWWyN3RAODk0312AlLtGi8vD/U2sqqSNaoLy1QU=";
    })
    (fetchzip {
      name = "toneshifteq-lv2";
      url = "https://github.com/brummer10/ToneShiftEQ/releases/download/v${finalAttrs.version}/ToneShiftEQ-v${finalAttrs.version}-lv2-linux-x86_64.tar.xz";
      hash = "sha256-yqkh6fHYA4SOtb3wGa60gcc/vGNyp3UBB+Y0/A926ic=";
    })
    (fetchzip {
      name = "toneshifteq-vst3";
      url = "https://github.com/brummer10/ToneShiftEQ/releases/download/v${finalAttrs.version}/ToneShiftEQ-v${finalAttrs.version}-vst3-linux-x86_64.tar.xz";
      hash = "sha256-p//f7mTayrD2HaS5Wy3tM+Jr3oXO+ZonVh50z6r31So=";
    })
    (fetchzip {
      name = "toneshifteq-app";
      url = "https://github.com/brummer10/ToneShiftEQ/releases/download/v${finalAttrs.version}/ToneShiftEQ-app-v${finalAttrs.version}-linux-x86_64.tar.xz";
      hash = "sha256-nMi0eieZJbXm2kgRej/7jtZDNjNHbxKN06/ABPVBicQ=";
    })
  ];

  dontUnpack = true;

  # Each fetchzip output is already unpacked (single file or bundle);
  # merge them into work/ and sort by extension below.
  installPhase = ''
    runHook preInstall
    mkdir -p work
    for a in $srcs; do cp -r "$a/"* work/; done
    mkdir -p $out/lib/clap $out/lib/lv2 $out/lib/vst3 $out/bin
    for f in work/*; do
      case "$f" in
        *.clap) cp "$f" $out/lib/clap/ ;;
        *.lv2) cp -r "$f" $out/lib/lv2/ ;;
        *.vst3) cp -r "$f" $out/lib/vst3/ ;;
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
    "vst3"
  ];

  meta = {
    description = "ToneShiftEQ (parametric equalizer)";
    homepage = "https://github.com/brummer10/ToneShiftEQ";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
