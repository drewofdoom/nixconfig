# blackstar-only home config (gaming machine).
#
# The podcast REAPER MCP + reaper-daemon bridge used to live here. They were
# dropped when REAPER moved to reaper-flake (see proaudio/default.nix); re-wire
# them against the new declarative setup when needed.
{ pkgs, ... }:

{
  # Niri monitor layout + input config for this machine's displays
  # (DP-1 ultrawide + HDMI-A-1 utility). Shared niri config lives in
  # home/desktop/niri.nix; config.kdl includes this as "hardware.kdl".
  xdg.configFile."niri/hardware.kdl".source = ./niri/hardware.kdl;

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
