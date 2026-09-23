# REAPER + Xephyr + Fluxbox nested X11 session.
#
# REAPER runs inside a lightweight nested X11 server (Xephyr) with Fluxbox as
# the window manager, avoiding XWayland/Swell issues entirely.
#
# Provides:
#   - ~/.nix-profile/bin/reaper-xephyr.sh — launch script
#   - ~/.local/share/applications/reaper-xephyr.desktop — desktop entry
#   - ~/.config/umbriel/fluxbox-reaper/ — dedicated Fluxbox config
#
# Per-host resolution can be set via programs.reaper-xephyr.width / .height.
{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.programs.reaper-xephyr;

  # Wrap the standalone scripts so they appear in PATH
  launchScript = pkgs.runCommand "reaper-xephyr-sh" { } ''
    install -Dm755 ${./reaper-xephyr.sh} $out/bin/reaper-xephyr.sh
  '';

  xwaylandScript = pkgs.runCommand "reaper-xwayland-sh" { } ''
    install -Dm755 ${./reaper-xwayland.sh} $out/bin/reaper-xwayland.sh
  '';

  # Desktop entry for the launcher (Mod+Space -> "REAPER (Xephyr)")
  desktopEntry = pkgs.makeDesktopItem {
    name = "reaper-xephyr";
    desktopName = "REAPER (Xephyr)";
    comment = "REAPER inside a nested Xephyr + Fluxbox session";
    exec = "reaper-xephyr.sh %F";
    icon = "cockos-reaper";
    categories = [
      "Audio"
      "AudioVideo"
    ];
    startupNotify = false;
  };

  # Desktop entry for the dedicated-Xwayland launcher
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
  options.programs.reaper-xephyr = {
    enable = lib.mkEnableOption "REAPER Xephyr nested session";

    width = lib.mkOption {
      type = lib.types.int;
      default = 3253;
      description = "Default width of the Xephyr window (pixels).";
    };

    height = lib.mkOption {
      type = lib.types.int;
      default = 1420;
      description = "Default height of the Xephyr window (pixels).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install the launch scripts and desktop entries
    home.packages = [
      launchScript
      desktopEntry
      xwaylandScript
      xwaylandEntry
    ];

    # Deploy Fluxbox config to ~/.config/umbriel/fluxbox-reaper/
    home.file.".config/umbriel/fluxbox-reaper/keys".source = ./fluxbox/keys;
    home.file.".config/umbriel/fluxbox-reaper/init".source = ./fluxbox/init;
    home.file.".config/umbriel/fluxbox-reaper/menu".source = ./fluxbox/menu;
    home.file.".config/umbriel/fluxbox-reaper/apps".source = ./fluxbox/apps;
    home.file.".config/umbriel/fluxbox-reaper/windowmenu".source = ./fluxbox/windowmenu;
    home.file.".config/umbriel/fluxbox-reaper/style".source = ./fluxbox/style;

    # Write a wrapper script that reads the configured defaults
    home.file.".config/umbriel/fluxbox-reaper/env".text = ''
      REAPER_XEPHYR_WIDTH=${toString cfg.width}
      REAPER_XEPHYR_HEIGHT=${toString cfg.height}
    '';
  };
}
