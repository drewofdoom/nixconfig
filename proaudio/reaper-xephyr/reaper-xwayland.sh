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

# Fluxbox config directory (managed by Home Manager, shared with xephyr module)
FLUXBOX_RC="${FLUXBOX_RC:-$HOME/.config/umbriel/fluxbox-reaper/init}"

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

XWAYLAND_RUN="$(command -v xwayland-run || echo '')"
if [ -z "$XWAYLAND_RUN" ]; then
  echo "ERROR: xwayland-run not found in PATH." >&2
  exit 1
fi

exec "$XWAYLAND_RUN" -- "$0" --inner "$@"
