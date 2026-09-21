# blackstar-only home config (gaming machine).
#
# The podcast REAPER MCP + reaper-daemon bridge used to live here. They were
# dropped when REAPER moved to reaper-flake (see proaudio/default.nix); re-wire
# them against the new declarative setup when needed.
{ pkgs, ... }:

{
  imports = [
    ./gamescope.nix
  ];

  home.packages = with pkgs; [
    heroic
    protonplus
    protontricks
    gamescope
    mangohud

    # keep uv available for ad-hoc pip work
    uv
  ];
}
