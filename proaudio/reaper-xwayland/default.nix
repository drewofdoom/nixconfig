# REAPER on a dedicated Xwayland server with Fluxbox.
#
# xwayland-satellite provides no window manager, so REAPER's floating
# FX/plugin windows are unmanageable. Fluxbox parents those transient windows
# so they appear as regular Umbriel windows — without trapping REAPER inside
# a nested Xephyr container.
#
# Provides:
#   - ~/.nix-profile/bin/reaper-xwayland.sh — launch script
#   - ~/.local/share/applications/reaper-xwayland.desktop — desktop entry
#   - ~/.fluxbox/ — dedicated Fluxbox config (upstream default location)
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
    comment = "REAPER on a dedicated Xwayland server with Fluxbox (floating windows as native windows)";
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
    ];

    # Deploy Fluxbox config to ~/.fluxbox/ (upstream default location)
    home.file.".fluxbox/keys".source = ./fluxbox/keys;
    home.file.".fluxbox/init".source = ./fluxbox/init;
    home.file.".fluxbox/menu".source = ./fluxbox/menu;
    home.file.".fluxbox/apps".source = ./fluxbox/apps;
    home.file.".fluxbox/windowmenu".source = ./fluxbox/windowmenu;
    home.file.".fluxbox/style".source = ./fluxbox/style;
  };
}
