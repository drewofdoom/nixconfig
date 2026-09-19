# Pro-audio setup, all hosts: REAPER + extensions, declaratively via
# reaper-flake (github:9Prestidigitator/reaper-flake, input `reaper-flake`).
# Plugin packages (nixpkgs + GitHub) live in ./plugins.
#
# reaper-flake owns REAPER's resource dir (~/.config/reaper-flake by default)
# and merges only the values declared here, leaving the rest of REAPER's
# mutable state alone. It also packages REAPER, SWS and a patched ReaPack, so
# the old nixpkgs reaper-{sws,reapack}-extension symlinks are gone.
{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./plugins
    inputs.reaper-flake.homeModules.reaper
    ./reaper.nix
  ];
}
