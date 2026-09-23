#!/usr/bin/env bash
# reaper-autolink: keep REAPER's input ports cabled to a chosen capture device.
#
# WirePlumber tends to auto-cable the default mic into REAPER's inputs, and
# links vanish on hotplug/restart. This watcher reconciles every INTERVAL
# seconds: pairs the device's capture ports to REAPER:in1/in2/... and, in
# exclusive mode, drops links from anything else.
#
#   REAPER_INPUT_MATCH      substring of the device's PipeWire port name
#                           (e.g. "ioStation", "Scarlett"); empty = exit, no-op
#   REAPER_INPUT_EXCLUSIVE  1 (default) remove non-device links into REAPER
#                           inputs; 0 = additive (record several sources)
#   REAPER_AUTOLINK_INTERVAL  reconcile period in seconds (default 2)
#   REAPER_AUTOLINK_ONCE    1 = single pass then exit (default: loop forever)
#
# All links are live graph edits via pw-link — ephemeral, nothing on disk.
set -uo pipefail

MATCH="${REAPER_INPUT_MATCH:-}"
EXCLUSIVE="${REAPER_INPUT_EXCLUSIVE:-1}"
INTERVAL="${REAPER_AUTOLINK_INTERVAL:-2}"
ONCE="${REAPER_AUTOLINK_ONCE:-0}"

[ -z "$MATCH" ] && exit 0
command -v pw-link >/dev/null || { echo "[autolink] pw-link not found" >&2; exit 0; }

device_ports() {
  local all cap
  all="$(pw-link -o 2>/dev/null | grep -iE "$MATCH" || true)"
  cap="$(grep -iE 'capture' <<<"$all" || true)"
  if [ -n "$cap" ]; then
    sort -V <<<"$cap"
  else
    [ -n "$all" ] && sort -V <<<"$all"
  fi
}

reconcile() {
  local -a rin dev
  mapfile -t rin < <(pw-link -i 2>/dev/null | grep -E '^REAPER:in[0-9]+$' | sort -V)
  [ "${#rin[@]}" -eq 0 ] && return 0  # REAPER not up yet
  mapfile -t dev < <(device_ports)
  [ "${#dev[@]}" -eq 0 ] && return 0   # device absent — leave graph alone

  local n="${#rin[@]}"
  [ "${#dev[@]}" -lt "$n" ] && n="${#dev[@]}"
  local i
  for ((i = 0; i < n; i++)); do
    pw-link "${dev[i]}" "${rin[i]}" 2>/dev/null \
      && echo "[autolink] linked ${dev[i]} -> ${rin[i]}"
  done

  if [ "$EXCLUSIVE" = "1" ]; then
    local node dst src
    node=""
    while IFS= read -r line; do
      if [[ "$line" =~ ^[^[:space:]] ]]; then
        node="${line%% *}"
      elif [[ "$node" =~ ^REAPER:in[0-9]+$ && "$line" == *"|<-"* ]]; then
        src="${line##*<- }"
        src="${src%% *}"
        grep -qiE "$MATCH" <<<"$src" && continue
        pw-link -d "$src" "$node" 2>/dev/null \
          && echo "[autolink] removed stray $src -> $node"
      fi
    done < <(pw-link -l 2>/dev/null)
  fi
}

if [ "$ONCE" = "1" ]; then
  reconcile
else
  while true; do reconcile; sleep "$INTERVAL"; done
fi
