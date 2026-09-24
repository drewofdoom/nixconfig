# giang17/wine experimental D2D1/DirectComposition fork (branch
# d2d1-dcomp-11.18) for Windows VST GUIs that stock Wine can't draw
# (JUCE 8 / VSTGUI black-window plugins under yabridge).
#
# PINNED — no auto-update. Re-pin by updating rev + hash below when YOU want
# a rebuild. Based on wineWow64Packages.full (dual-arch
# --enable-archs=x86_64,i386, which the fork requires), NOT staging
# (staging patches would collide with the fork's own diff).
#
# Build on blackstar only (long compile — not the old laptop):
#   nix build .#wine-d2d1
# Deliberately NOT in any profile (bin/wine would collide with the staging
# build). Invoke by store path with a DEDICATED prefix, never an existing one:
#   WINEPREFIX=~/.local/share/wineprefixes/d2d1-test \
#     ./result/bin/wine winecfg
# Leave DXVK out of test prefixes — the fork's dxgi IS the point.
{
  wineWow64Packages,
  fetchzip,
  lib,
}:

wineWow64Packages.full.overrideAttrs (old: {
  version = "11.18-d2d1-dcomp";
  src = fetchzip {
    url = "https://github.com/giang17/wine/archive/fa70e75758526f974874dfde223b47abe1cb5c13.tar.gz";
    hash = "sha256-6eOh0zw5bUos8c9q2yFDm0LU3UKo9cY4HLvGu+yZmFg=";
  };
  # The fork already carries nixpkgs' add-dll-accept-device-paths change
  # (upstream's patch detects as reversed), so drop it; keep the rest
  # (cert-path applied cleanly against 11.18).
  patches = builtins.filter (
    p: !(lib.hasInfix "add-dll-accept-device-paths" (toString p))
  ) old.patches;
})
