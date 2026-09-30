# Pro-audio setup, all hosts.
#
# The REAPER configuration itself lives in ./reaper/, split one file per major
# section (see reaper/default.nix for the index). This file is just the
# top-level entry point: the section modules, the extension modules, and the
# plugin packages REAPER discovers via the profile.
#
# reasonus-native/ stays a sibling of reaper/: it is a self-contained extension
# build (source, calibration scripts, its own module) rather than part of the
# REAPER settings graph.
{
  imports = [
    ./reaper
    ./reasonus-native/module.nix
    ./plugins.nix
  ];
}
