#!/usr/bin/env bash
# Launch REAPER inside a nested Xephyr + Fluxbox session.
# This avoids XWayland/Swell issues by running REAPER in a pure X11 environment
# with a lightweight stacking WM that uses Alt (not Super) for window ops.

set -euo pipefail

DISPLAY_NUM="${DISPLAY_NUM:-1}"

# Source per-host defaults if available
if [ -f "$HOME/.config/umbriel/fluxbox-reaper/env" ]; then
  . "$HOME/.config/umbriel/fluxbox-reaper/env"
fi

WIDTH="${WIDTH:-${REAPER_XEPHYR_WIDTH:-3253}}"
HEIGHT="${HEIGHT:-${REAPER_XEPHYR_HEIGHT:-1420}}"
XEPHYR_DISPLAY=":$DISPLAY_NUM"

# Resolve Xephyr from nixpkgs if not in PATH
XEPHYR="$(command -v Xephyr || nix-shell -p xorg-server --run 'which Xephyr' 2>/dev/null || echo '')"
if [ -z "$XEPHYR" ]; then
  echo "ERROR: Xephyr not found. Install it: nix profile install nixpkgs#xorg-server" >&2
  exit 1
fi

# Resolve xdpyinfo for readiness check
XDPYINFO="$(command -v xdpyinfo || nix-shell -p xdpyinfo --run 'which xdpyinfo' 2>/dev/null || echo '')"

# Fluxbox config directory (managed by Home Manager)
FLUXBOX_RC="${FLUXBOX_RC:-$HOME/.config/umbriel/fluxbox-reaper/init}"

# Start Xephyr nested window.
# No -resizeable: keeps XRandR disabled so Xephyr reports the exact screen
# size we request instead of inheriting host monitor geometry.
"$XEPHYR" "$XEPHYR_DISPLAY" \
  -ac \
  -screen "${WIDTH}x${HEIGHT}" \
  -title "REAPER (Xephyr)" \
  -noreset \
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
sleep 1

# Launch REAPER inside the nested session
DISPLAY="$XEPHYR_DISPLAY" reaper "$@" &
REAPER_PID=$!

# Wait for REAPER to exit, then clean up
wait "$REAPER_PID" 2>/dev/null || true
kill "$FLUXBOX_PID" 2>/dev/null || true
kill "$XEPHYR_PID" 2>/dev/null || true
wait 2>/dev/null || true
