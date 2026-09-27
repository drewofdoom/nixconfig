#!/usr/bin/env bash
# Screen recorder for Umbriel (wlroots compositor, uses wlr-screencopy-v1).
#
#   screen-record          record the region picked with slurp
#   screen-record --full   record the whole output
#
# Re-running while a recording is active stops it (wf-recorder finalises the
# file on SIGINT), so the same keybind both starts and stops.
#
# Files land in ~/Videos/screenrecord-<date>.mp4. State lives in
# $XDG_RUNTIME_DIR/screen-record; wf-recorder's own output goes to
# .../log, since it runs detached in the background.
set -euo pipefail

runtime="${XDG_RUNTIME_DIR:-/tmp}/screen-record"
pidfile="$runtime/pid"
outdir="$HOME/Videos"

mkdir -p "$runtime"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send --app-name="Screen record" --expire-time=4000 "$1" "${2-}"
  fi
}

recording() {
  [ -f "$pidfile" ] || return 1
  read -r pid _ <"$pidfile"
  [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null
}

stop() {
  if ! recording; then
    rm -f "$pidfile"
    notify "Not recording"
    return
  fi
  read -r pid out <"$pidfile"
  kill -INT "$pid"
  # let ffmpeg close the file before the user looks for it
  for _ in $(seq 1 100); do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.1
  done
  rm -f "$pidfile"
  notify "Saved" "$out"
}

start() {
  local args=(-y --audio)
  local label="full screen"

  if [ "${1-}" != "--full" ]; then
    local geom
    geom="$(slurp)" || geom=""
    if [ -z "$geom" ]; then
      notify "Cancelled" "No region selected"
      return
    fi
    args+=(-g "$geom")
    label="region $geom"
  fi

  mkdir -p "$outdir"
  local out="$outdir/screenrecord-$(date +%F-%H%M%S).mp4"
  args+=(-f "$out")

  # --audio records the default source; libx264 software encode is the
  # reliable path on NVIDIA (VAAPI needs -x yuv420p and is flaky here).
  wf-recorder "${args[@]}" >"$runtime/log" 2>&1 &
  printf '%s\n%s\n' "$!" "$out" >"$pidfile"

  notify "Recording $label" "Press Super+Shift+R again to stop"
}

if recording; then
  stop
else
  start "${1-}"
fi
