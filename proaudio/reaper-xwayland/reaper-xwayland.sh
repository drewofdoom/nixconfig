#!/usr/bin/env bash
# Launch REAPER on a dedicated Xwayland server with Fluxbox as WM.
# Unlike xwayland-satellite (no WM — REAPER's floating FX/plugin windows are
# unmanageable), Fluxbox parents those transient windows so they appear as
# regular Umbriel windows. Unlike the Xephyr script, REAPER windows are NOT
# trapped inside a nested container — each one is its own Wayland surface.
#
# Cleanup is automatic: xwayland-run puts itself in its own process group and
# SIGTERMs the group when the client exits, so Fluxbox + Xwayland die with
# REAPER. The trap below is a belt-and-braces fallback.
#
# Usage: reaper-xwayland.sh [reaper args...]

set -euo pipefail

# Fluxbox config (managed by Home Manager at the upstream default ~/.fluxbox/)
FLUXBOX_RC="${FLUXBOX_RC:-$HOME/.fluxbox/init}"

if [ "${1:-}" = "--inner" ]; then
  # Running INSIDE the dedicated Xwayland server (DISPLAY already set).
  shift
  fluxbox -rc "$FLUXBOX_RC" &
  FLUXBOX_PID=$!
  trap 'kill "$FLUXBOX_PID" 2>/dev/null || true' EXIT
  # Give Fluxbox a moment to take ownership of the display (same as xephyr script)
  sleep 1
  exec reaper "$@"
fi

# X desktop size (Xwayland -geometry, rootful mode). Override per launch:
#   REAPER_GEOMETRY=4096x1152 reaper-xwayland.sh
REAPER_GEOMETRY="${REAPER_GEOMETRY:-2560x1132}"

XWAYLAND_RUN="$(command -v xwayland-run || echo '')"
if [ -z "$XWAYLAND_RUN" ]; then
  echo "ERROR: xwayland-run not found in PATH." >&2
  exit 1
fi

exec "$XWAYLAND_RUN" -geometry "$REAPER_GEOMETRY" -- "$0" --inner "$@"
