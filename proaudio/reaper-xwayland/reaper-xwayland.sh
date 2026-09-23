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
#
# Optional env:
#   REAPER_INPUT_MATCH      substring of your interface's PipeWire port name
#                           (e.g. "ioStation"). Starts the autolink watcher,
#                           which keeps the device cabled to REAPER:in1/in2
#                           across hotplug/restarts and evicts WirePlumber's
#                           default-mic auto-links. See reaper-autolink.sh.
#   REAPER_INPUT_EXCLUSIVE  0 = additive (record several sources at once).
#                           Default 1.
#   REAPER_LOWLATENCY=1     tracking mode: request a 128-sample PipeWire
#                           quantum (override size with REAPER_QUANTUM, e.g.
#                           "256/48000"). Unset = default quantum (mixing).

set -euo pipefail

# Fluxbox config (managed by Home Manager at the upstream default ~/.fluxbox/)
FLUXBOX_RC="${FLUXBOX_RC:-$HOME/.fluxbox/init}"

# reaper-autolink.sh is installed to PATH by the same home-manager module.
AUTOLINK="$(command -v reaper-autolink.sh || echo '')"

if [ "${1:-}" = "--inner" ]; then
  # Running INSIDE the dedicated Xwayland server (DISPLAY already set).
  shift
  fluxbox -rc "$FLUXBOX_RC" &
  FLUXBOX_PID=$!
  trap 'kill "$FLUXBOX_PID" ${AUTOLINK_PID:+$AUTOLINK_PID} 2>/dev/null || true' EXIT
  # Optional input auto-cabling (no-op unless REAPER_INPUT_MATCH is set).
  if [ -n "${REAPER_INPUT_MATCH:-}" ] && [ -x "$AUTOLINK" ]; then
    "$AUTOLINK" &
    AUTOLINK_PID=$!
  fi
  # Give Fluxbox a moment to take ownership of the display (same as xephyr script)
  sleep 1
  if [ "${REAPER_LOWLATENCY:-0}" = "1" ]; then
    export PIPEWIRE_LATENCY="${REAPER_QUANTUM:-128/48000}"
  fi
  exec reaper "$@"
fi

XWAYLAND_RUN="$(command -v xwayland-run || echo '')"
if [ -z "$XWAYLAND_RUN" ]; then
  echo "ERROR: xwayland-run not found in PATH." >&2
  exit 1
fi

exec "$XWAYLAND_RUN" -- "$0" --inner "$@"
