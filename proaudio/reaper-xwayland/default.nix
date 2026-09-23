# REAPER on a dedicated Xwayland server with Openbox.
#
# xwayland-satellite provides no window manager, so REAPER's floating
# FX/plugin windows are unmanageable. Openbox parents those transient windows
# so they behave — without trapping REAPER inside a nested Xephyr container.
#
# Provides:
#   - ~/.nix-profile/bin/reaper-xwayland.sh — launch script
#   - ~/.local/share/applications/reaper-xwayland.desktop — desktop entry
#   - ~/.config/reaper-openbox/rc.xml + ~/.themes/Reaper/ — Openbox config/theme
#
{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.programs.reaper-xwayland;

  xwaylandScript = pkgs.runCommand "reaper-xwayland-sh" { } ''
    install -Dm755 ${./reaper-xwayland.sh} $out/bin/reaper-xwayland.sh
  '';

  xwaylandEntry = pkgs.makeDesktopItem {
    name = "reaper-xwayland";
    desktopName = "REAPER (Xwayland)";
    comment = "REAPER on a dedicated Xwayland server with Openbox";
    exec = "reaper-xwayland.sh %F";
    icon = "cockos-reaper";
    categories = [
      "Audio"
      "AudioVideo"
    ];
    startupNotify = false;
  };

in
{
  options.programs.reaper-xwayland = {
    enable = lib.mkEnableOption "REAPER dedicated-Xwayland session";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      xwaylandScript
      xwaylandEntry
      pkgs.openbox
    ];

    # Openbox config (kept out of ~/.config/openbox so a future native
    # openbox session isn't hijacked) + "Reaper" theme
    home.file.".config/reaper-openbox/rc.xml".source = ./openbox/rc.xml;
    home.file.".themes/Reaper/openbox-3/themerc".source = ./openbox/Reaper-themerc;
  };
}
