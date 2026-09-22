# Home Manager module: installs plugin packages (nixpkgs + GitHub flake
# packages), symlinks the GitHub ones into the user plugin search paths,
# and puts their standalones on PATH.
#
# Convention: each GitHub plugin derivation installs formats to $out/<format>
# and declares them in passthru.formats (see zl-equalizer.nix template).
# Adding a GitHub plugin = new file in this dir + one line in flake.nix
# `packages`. Adding a nixpkgs plugin = one line in `nixpkgsPlugins` below.
{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  plugins = lib.attrValues inputs.self.packages.${system};

  # $out/<format> -> ~/.<format>/github/<pname>. Hosts recurse into
  # subdirs; the `github/` namespace keeps Nix-managed plugins separate from
  # hand-installed ones already in these dirs (and from each other).
  formatDir = {
    clap = ".clap";
    vst3 = ".vst3";
    vst2 = ".vst";
    lv2 = ".lv2";
    ladspa = ".ladspa";
  };

  filesFor =
    pkg:
    lib.listToAttrs (
      map (fmt: {
        name = "${formatDir.${fmt}}/github/${pkg.pname}";
        value.source = "${pkg}/${fmt}";
      }) (pkg.formats or [ ])
    );

  # Plugins installed straight from nixpkgs (no repackaging needed).
  nixpkgsPlugins = with pkgs; [
    surge-xt
    dragonfly-reverb
    x42-plugins
    zam-plugins
    vital
    odin2
    dexed
    chow-tape-model
    # cardinal
  ];
in
{
  home.packages = plugins ++ nixpkgsPlugins ++ [ pkgs.nix-update ];

  home.file = lib.mkMerge (map filesFor plugins);
}
