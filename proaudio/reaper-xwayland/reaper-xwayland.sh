#!/usr/bin/env bash
# Launch REAPER on a dedicated Xwayland server with Openbox as WM.
# Unlike xwayland-satellite (no WM — REAPER's floating FX/plugin windows are
# unmanageable), Openbox parents those transient windows so they behave.
# Unlike Xephyr, REAPER windows are NOT trapped in a nested container.
#
# Cleanup is automatic: xwayland-run puts itself in its own process group and
# SIGTERMs the group when the client exits, so Openbox + Xwayland die with
# REAPER. The trap below is a belt-and-braces fallback.
#
# Usage: reaper-xwayland.sh [reaper args...]

set -euo pipefail

# Openbox config (managed by Home Manager; kept out of ~/.config/openbox so a
# future native openbox session isn't hijacked)
OPENBOX_RC="${OPENBOX_RC:-$HOME/.config/reaper-openbox/rc.xml}"

if [ "${1:-}" = "--inner" ]; then
  # Running INSIDE the dedicated Xwayland server (DISPLAY already set).
  shift
  command -v openbox >/dev/null || { echo "ERROR: openbox not found in PATH." >&2; exit 1; }
  openbox --config-file "$OPENBOX_RC" &
  WM_PID=$!
  trap 'kill "$WM_PID" 2>/dev/null || true' EXIT
  exec reaper "$@"
fi

XWAYLAND_RUN="$(command -v xwayland-run || echo '')"
if [ -z "$XWAYLAND_RUN" ]; then
  echo "ERROR: xwayland-run not found in PATH." >&2
  exit 1
fi

exec "$XWAYLAND_RUN" -- "$0" --inner "$@"
