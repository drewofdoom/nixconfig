# SmoothIR (convolution reverb / IR loader). See brummer-loopino.nix for
# the multi-asset pattern (one asset per format, sorted by extension).
#
# Tags are v-prefixed; if `nix-update brummer-smoothir --flake` misreads the
# version, retry with `--version-regex 'v(.*)'`.
{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brummer-smoothir";
  version = "0.3";

  srcs = [
    (fetchzip {
      name = "smoothir-clap";
      url = "https://github.com/brummer10/SmoothIR/releases/download/v${finalAttrs.version}/SmoothIR-v${finalAttrs.version}-clap-linux-x86_64.tar.xz";
      hash = "sha256-mMlZ6zyH7UZMJweRcYM5laSRwDpGiL05S4uWQUkzldY=";
    })
    (fetchzip {
      name = "smoothir-app";
      url = "https://github.com/brummer10/SmoothIR/releases/download/v${finalAttrs.version}/SmoothIR-app-v${finalAttrs.version}-linux-x86_64.tar.xz";
      hash = "sha256-5PYpvQYAx7uzCQQmzf7SKHHnzL0NgCahB57EOjvEVM0=";
    })
  ];

  dontUnpack = true;

  # Each fetchzip output is already unpacked (single file or bundle);
  # merge them into work/ and sort by extension below.
  installPhase = ''
    runHook preInstall
    mkdir -p work
    for a in $srcs; do cp -r "$a/"* work/; done
    mkdir -p $out/lib/clap $out/bin
    for f in work/*; do
      case "$f" in
        *.clap) cp "$f" $out/lib/clap/ ;;
        *)
          if [ -f "$f" ] && [ -x "$f" ]; then cp "$f" $out/bin/; fi
          ;;
      esac
    done
    runHook postInstall
  '';

  passthru.formats = [ "clap" ];

  meta = {
    description = "SmoothIR (convolution reverb / IR loader)";
    homepage = "https://github.com/brummer10/SmoothIR";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
