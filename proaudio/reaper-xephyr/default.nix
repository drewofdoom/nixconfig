# REAPER + Xephyr + Fluxbox nested X11 session.
#
# REAPER runs inside a lightweight nested X11 server (Xephyr) with Fluxbox as
# the window manager, avoiding XWayland/Swell issues entirely.
#
# Provides:
#   - ~/.nix-profile/bin/reaper-xephyr.sh — launch script
#   - ~/.local/share/applications/reaper-xephyr.desktop — desktop entry
#   - ~/.config/umbriel/fluxbox-reaper/ — dedicated Fluxbox config
{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.programs.reaper-xephyr;

  # The launch script, patched to point at the Nix-managed Fluxbox config
  launchScript = pkgs.writeShellScriptBin "reaper-xephyr.sh" ''
    #!/usr/bin/env bash
    set -euo pipefail

    DISPLAY_NUM="''${DISPLAY_NUM:-1}"
    WIDTH="''${WIDTH:-1920}"
    HEIGHT="''${HEIGHT:-1080}"
    XEPHYR_DISPLAY=":$DISPLAY_NUM"

    # Resolve Xephyr from nixpkgs if not in PATH
    XEPHYR="$(command -v Xephyr || nix-shell -p xorg-server --run 'which Xephyr' 2>/dev/null || echo '')"
    if [ -z "$XEPHYR" ]; then
      echo "ERROR: Xephyr not found. Install it: nix profile install nixpkgs#xorg-server" >&2
      exit 1
    fi

    # Resolve xdpyinfo for readiness check
    XDPYINFO="$(command -v xdpyinfo || nix-shell -p xorg.xdpyinfo --run 'which xdpyinfo' 2>/dev/null || echo '')"

    # Fluxbox config directory (managed by Home Manager)
    FLUXBOX_RC="''${FLUXBOX_RC:-$HOME/.config/umbriel/fluxbox-reaper/init}"

    # Start Xephyr nested window
    "$XEPHYR" "$XEPHYR_DISPLAY" \
      -ac \
      -screen "''${WIDTH}x''${HEIGHT}" \
      -title "REAPER (Xephyr)" \
      -noreset \
      -resizeable \
      -softCursor \
      -name "reaper-xephyr" &
    XEPHYR_PID=$!

    # Wait for Xephyr to be ready
    if [ -n "$XDPYINFO" ]; then
      for i in $(seq 1 20); do
        if "$XDPYINFO" -display "$XEPHYR_DISPLAY" >/dev/null 2>&1; then
          break
        fi
        sleep 0.2
      done
    else
      sleep 2
    fi

    # Start Fluxbox inside Xephyr with the dedicated REAPER config
    DISPLAY="$XEPHYR_DISPLAY" fluxbox \
      -rc "$FLUXBOX_RC" &
    FLUXBOX_PID=$!

    # Wait a moment for Fluxbox to start
    sleep 0.5

    # Launch REAPER inside the nested session
    DISPLAY="$XEPHYR_DISPLAY" reaper "$@" &
    REAPER_PID=$!

    # Wait for REAPER to exit, then clean up
    wait "$REAPER_PID" 2>/dev/null || true
    kill "$FLUXBOX_PID" 2>/dev/null || true
    kill "$XEPHYR_PID" 2>/dev/null || true
    wait 2>/dev/null || true
  '';

  # Desktop entry for the launcher (Mod+Space → "REAPER (Xephyr)")
  desktopEntry = pkgs.makeDesktopItem {
    name = "reaper-xephyr";
    desktopName = "REAPER (Xephyr)";
    comment = "REAPER inside a nested Xephyr + Fluxbox session";
    exec = "reaper-xephyr.sh %F";
    icon = "reaper";
    categories = [ "Audio" "AudioVideo" ];
    startupNotify = false;
  };

  # Fluxbox config files to deploy
  fluxboxConfig = pkgs.symlinkJoin {
    name = "fluxbox-reaper-config";
    paths = [
      ./fluxbox/keys
      ./fluxbox/init
      ./fluxbox/menu
      ./fluxbox/apps
      ./fluxbox/windowmenu
      ./fluxbox/style
    ];
  };

in
{
  options.programs.reaper-xephyr = {
    enable = lib.mkEnableOption "REAPER Xephyr nested session";
  };

  config = lib.mkIf cfg.enable {
    # Install the launch script and desktop entry
    home.packages = [
      launchScript
      desktopEntry
    ];

    # Deploy Fluxbox config to ~/.config/umbriel/fluxbox-reaper/
    home.file.".config/umbriel/fluxbox-reaper/keys".source = ./fluxbox/keys;
    home.file.".config/umbriel/fluxbox-reaper/init".source = ./fluxbox/init;
    home.file.".config/umbriel/fluxbox-reaper/menu".source = ./fluxbox/menu;
    home.file.".config/umbriel/fluxbox-reaper/apps".source = ./fluxbox/apps;
    home.file.".config/umbriel/fluxbox-reaper/windowmenu".source = ./fluxbox/windowmenu;
    home.file.".config/umbriel/fluxbox-reaper/style".source = ./fluxbox/style;
  };
}
