# Home Manager module: symlinks every flake audio-plugin package into the
# standard user plugin search paths, and puts their standalones on PATH.
#
# Convention: each plugin derivation installs formats to $out/<format> and
# declares them in passthru.formats (see zl-equalizer.nix template).
# Adding a plugin = new file in this dir + one line in flake.nix `packages`.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  plugins = lib.attrValues inputs.self.packages.${system};

  # $out/<format> -> ~/ search dir. Hosts recurse into subdirs, so each
  # plugin gets its own subfolder (avoids filename collisions with
  # hand-installed plugins already in these dirs).
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
        name = "${formatDir.${fmt}}/${pkg.pname}";
        value.source = "${pkg}/${fmt}";
      }) (pkg.formats or [ ])
    );
in
{
  home.packages = plugins ++ [ pkgs.nix-update ];

  home.file = lib.mkMerge (map filesFor plugins);
}
