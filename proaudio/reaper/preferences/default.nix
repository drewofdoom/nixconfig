# REAPER preference sections, one file per `programs.reaper.preferences.*`
# group. This file is only the index -- add a new group by dropping a file
# here rather than growing a monolithic module.
#
#   general.nix           -- filenames, language pack (+ GUI-owned settings note)
#   plug-ins.nix          -- VST/LV2/CLAP search paths, preset pin handling
#   editing-behavior.nix  -- mouse modifier contexts
{
  imports = [
    ./general.nix
    ./plug-ins.nix
    ./editing-behavior.nix
  ];
}
