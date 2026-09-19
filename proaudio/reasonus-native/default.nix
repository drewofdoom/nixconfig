# ReaSonus Native — REAPER control-surface extension for PreSonus FaderPort
# (v2 / ioStation 24c) and FaderPort 8/16.
#
# Upstream is a CMake project that pulls its dependencies over the network via
# FetchContent (WDL, reaper-sdk, GSL, mINI, fmt) and downloads a ReaImGui
# header at configure time. The Nix sandbox has no network, so every one of
# those is pinned here and injected through `postPatch` by rewriting the
# FetchContent_Declare blocks to point at local store paths.
#
# Linux build notes (upstream issue #29):
#   - The code relies on transitive includes that newer libstdc++ no longer
#     provides, so <cstdlib>/<cmath>/<cstring>/<cstdio> are force-included.
#   - SWELL_DLG_WS_DEFAULT_SCALING=0 disables SWELL's dialog window-scaling
#     path, which does not work correctly on Linux. Trade-off: dialogs do not
#     scale on HiDPI displays.
#
# Upstream's own install rules already place the artifacts exactly where
# REAPER wants them:
#   UserPlugins/reaper_ReasonusNative-x86_64.so
#   UserPlugins/ReaSonus/en-US.ini
# so `installPhase` just runs `cmake --install` into $out and the Home Manager
# module (./module.nix) links them into the REAPER resource dir.
{
  lib,
  stdenv,
  cmake,
  ninja,
  git,
  php,
  xxd,
  python3,
  fetchFromGitHub,
  fetchurl,
  # When true, the extension logs every raw 14-bit fader value it receives to
  # the REAPER console, for calibrating the fader range. See ./README.md.
  calibrate ? false,
}:

let
  # Pinned FetchContent dependencies. Refs that upstream tracks as moving
  # branches (WDL/GSL/mINI "origin/main") are frozen to the commit that was
  # HEAD when this derivation was written.
  reaper-sdk = fetchFromGitHub {
    owner = "justinfrankel";
    repo = "reaper-sdk";
    rev = "b6285401c89db5f06d42c5bcb9614fb603c08ba6";
    hash = "sha256-4LV755aXBmevG5ubjZUAlORVepQ3OsOOLcqILwMneuo=";
  };
  wdl = fetchFromGitHub {
    owner = "justinfrankel";
    repo = "WDL";
    rev = "8f4d783de745126ac8c201455dc30818c8613324";
    hash = "sha256-RvzjVUMTkX0iLM9vBHYLnilxn9g+YKKBLHfqLhaeYzU=";
  };
  gsl = fetchFromGitHub {
    owner = "microsoft";
    repo = "GSL";
    rev = "a16852b79452bdfa217381c6a5eab0b2975e2076";
    hash = "sha256-IXuh2+dIfDXKuJ9ID9HfBXW5ZQwsPZbRxnxfqHNsDD0=";
  };
  mini = fetchFromGitHub {
    owner = "metayeti";
    repo = "mINI";
    rev = "d882d7f4a42991fb3e4635eda8e8777e5b3cd153";
    hash = "sha256-LPHtxUuVQHaXBqsfvP49S2DG4cZlh8I7My4x2IsHeUU=";
  };
  fmt = fetchFromGitHub {
    owner = "fmtlib";
    repo = "fmt";
    rev = "e69e5f977d458f2650bb346dadf2ad30c5320281";
    hash = "sha256-pEltGLAHLZ3xypD/Ur4dWPWJ9BGVXwqQyKcDWVmC3co=";
  };
  reaimguiHeader = fetchurl {
    url = "https://github.com/cfillion/reaimgui/releases/download/v0.10.0.1/reaper_imgui_functions.h";
    hash = "sha256-klpcNGkeO6LRejMqsFMHP1zuLgywAFJIE15zUopJ2kM=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "reasonus-native";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "navelpluisje";
    repo = "Reasonus-Native";
    tag = finalAttrs.version;
    hash = "sha256-ym0TDq3JP9fmPV9u2J+C3RSkXHvGHEf0s3uQOj+DxEE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    git # CMakeLists runs `git describe` for versioning
    php # res.rc generation (swell_resgen.php)
    xxd # asset -> .ipp hex dumps
    python3 # CMakeLists rewriting in postPatch
  ];

  # The project vendors everything under ./lib via FetchContent. Pre-populate
  # that directory with the pinned sources so FetchContent finds them locally,
  # then strip the network instructions from CMakeLists.txt. Keeping upstream's
  # original lib/<name> layout matters: CMakeLists symlinks
  # lib/reaper-sdk/WDL -> lib/WDL/WDL and FindWDL/FindSWELL search under
  # lib/WDL, so the directory structure has to match.
  postPatch = ''
    mkdir -p lib/reaImgui
    cp ${reaimguiHeader} lib/reaImgui/reaper_imgui_functions.h

    cp -r ${reaper-sdk} lib/reaper-sdk
    cp -r ${wdl} lib/WDL
    cp -r ${gsl} lib/GSL
    cp -r ${mini} lib/mINI
    cp -r ${fmt} lib/fmt
    chmod -R u+w lib

    python3 - <<'PY'
    import re, pathlib

    p = pathlib.Path("CMakeLists.txt")
    s = p.read_text()

    # Drop the network fetch instructions; SOURCE_DIR already points at lib/.
    s = re.sub(r"^\s*GIT_REPOSITORY\s+.*$", "", s, flags=re.MULTILINE)
    s = re.sub(r"^\s*GIT_TAG\s+.*$", "", s, flags=re.MULTILINE)

    # Drop the runtime header download; we vendor it above.
    s = re.sub(
        r"file\(DOWNLOAD.*?reaper_imgui_functions\.h\)", "", s, flags=re.DOTALL
    )

    p.write_text(s)
    PY

    # Correct the fader taper for the ioStation 24c (see the script header).
    python3 ${./fader-calibration.py}
  ''
  + lib.optionalString calibrate ''
    # Log every fader value the device sends, plus the volume REAPER derives
    # from it, so the real travel range can be measured.
    python3 ${./calibrate.py}
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  # Linux fixes from upstream issue #29. Set in preConfigure so the
  # space-separated flags survive as a single argument (cmakeFlags is
  # word-split by the cmake hook).
  preConfigure = ''
    cmakeFlagsArray+=(
      "-DCMAKE_CXX_FLAGS=-include cstdlib -include cmath -include cstring -include cstdio -DSWELL_DLG_WS_DEFAULT_SCALING=0"
    )
  '';

  # Upstream installs to UserPlugins/ and UserPlugins/ReaSonus/ already, but
  # `cmake --install` also drags in fmt's headers/static lib. Keep only the
  # two artifacts REAPER actually loads.
  installPhase = ''
    runHook preInstall
    cmake --install . --prefix "$out"
    rm -rf "$out/include" "$out/lib"
    runHook postInstall
  '';

  meta = {
    description = "REAPER control-surface extension for PreSonus FaderPort (Native)";
    homepage = "https://github.com/navelpluisje/Reasonus-Native";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
