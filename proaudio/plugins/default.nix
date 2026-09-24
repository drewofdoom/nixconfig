# Home Manager module: installs plugin packages (nixpkgs + GitHub flake
# packages) into the user profile so they appear in
# ~/.nix-profile/lib/<format>, which REAPER already searches.
#
# Convention: each GitHub plugin derivation installs formats to
# $out/lib/<format> and declares them in passthru.formats
# (see zl-equalizer.nix template). Adding a GitHub plugin = new file in
# this dir + one line in flake.nix `packages`. Adding a nixpkgs plugin =
# one line in `nixpkgsPlugins` below.
{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  plugins = lib.attrValues inputs.self.packages.${system};

  # Plugins installed straight from nixpkgs (no repackaging needed).
  nixpkgsPlugins = with pkgs; [
    surge-xt
    dragonfly-reverb
    x42-plugins
    zam-plugins
    lsp-plugins
    cardinal
    vcv-rack
    vital
    odin2
    dexed
    chow-tape-model
  ];
in
{
  home.packages = plugins ++ nixpkgsPlugins;
}
