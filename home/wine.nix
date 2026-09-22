# Wine + yabridge bridge infrastructure. Moved verbatim from home-common.nix.
# Stays here rather than proaudio: it's bridge infrastructure, and the dev
# override lives in the let block below.
{
  pkgs,
  ...
}:

let
  # Recent yabridge dev build (actions run 30739764611, commit b580a9f).
  yabridge-dev = pkgs.yabridge.overrideAttrs (oldAttrs: {
    version = "5.1.1-57-gb580a9f";
    src = pkgs.fetchFromGitHub {
      owner = "robbert-vdh";
      repo = "yabridge";
      rev = "b580a9f7fc46509767ca156d4f92872552b9e571";
      hash = "sha256-TiKiyE3GZYCX1+vooHdD03fAhNQPAA1IzTfkG++I7TY=";
    };
    # nixpkgs' 32-bit/removal patches don't apply to this dev commit, but the
    # NIX_PROFILES lookup patch does (verified) and is required on NixOS so the
    # chainloader finds libyabridge-vst{2,3}.so from the user profile.
    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/NixOS/nixpkgs/raw/b1b875982b17dabde9b4a37f3e229e74913e6db3/pkgs/by-name/ya/yabridge/libyabridge-from-nix-profiles.patch";
        hash = "sha256-Ial9AkHvOfd1zR2uFBNPEKwpv/qgYxycZufEn9dXHl0=";
      })
    ];
  });
  yabridgectl-dev = pkgs.yabridgectl.overrideAttrs (oldAttrs: {
    version = "5.1.1-57-gb580a9f";
    src = pkgs.fetchFromGitHub {
      owner = "robbert-vdh";
      repo = "yabridge";
      rev = "b580a9f7fc46509767ca156d4f92872552b9e571";
      hash = "sha256-TiKiyE3GZYCX1+vooHdD03fAhNQPAA1IzTfkG++I7TY=";
    };
  });
in
{
  home.packages = with pkgs; [
    wineWow64Packages.stagingFull
    winetricks
    dxvk
    yabridge-dev
    yabridgectl-dev
  ];

  # winetricks needs wine64 on PATH; ~/.local/bin is more reliably in scope
  # than the Nix profile path depending on how it's invoked.
  home.file.".local/bin/wine64".source = "${pkgs.wineWow64Packages.stagingFull}/bin/wine64";
}
