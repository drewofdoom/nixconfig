# REAPER durable memory (global)

Two MCP servers are configured. No fixed priority — pick the best tool
for a stable, reversible outcome per task.

## Defaults
- Podcast work defaults to the podcast profile (xDarkzx filtered +
  daemon full — see below). That combination is the intended setup,
  not a degraded mode.
- The podcast filter applies ONLY to xDarkzx. `reaper-daemon` always
  exposes its full toolset, so nothing is lost by staying in the
  podcast profile.

## Selection policy (best tool, stable outcome)
- Dialogue/item/marker/QC/save/export: prefer xDarkzx (`reaper_*`).
- Mix values, automation, render-settings introspection, measured
  moves, GUID-pinned edits: prefer daemon. Use `dry_run` when target
  or effect is uncertain; `batch` for one-undo multi-edits.
- File bridge CLI is the fallback when either MCP is down, or for
  scripting: `python3 reaperd.py status` / `... send <json> --wait`.
- Stability rules: `project_backup` before destructive work; confirm
  intent for deletes/overwrites/renders; read back what was written
  (`applied`, `get_context`, `project_get_overview`); renders and
  render-settings are NOT undoable — restore settings after tweaking.

## Servers
- `reaper` = xDarkzx `reaper-mcp`, profile `reaper-podcast.toml`.
  Post-production: transport, track, project, item, take, marker/region,
  selection, envelope, send, fx chain + params + inventory, analysis
  (silence/peaks/region_qc/loudness/spectrum/stereo/clipping), script, chops.
  Renders: `project_export_audio` master/stems, wav/mp3/ogg/flac/aiff.
  Save: `project_save`, `project_save_as`, `project_backup`, `project_undo/redo`.
- `reaper-daemon` = `python3 /home/drew/Projects/reaper-daemon/reaper_mcp.py`.
  Mix/measure: `get_status`, `get_context` (stable GUIDs), `scan_fx`,
  `get_fx_parameters`, `set_fx_param` (formatted values like "-16.00 dB"),
  automation read/write, `batch` (one undo block), `capture_track_audio`,
  `insert_riff / cut_band / humanize_take / insert_groove`,
  `verify_change / tune_param`, `mix_recipe`, `raw_command` escape hatch.
  Render introspection: `get_render_settings` / `set_render_settings` /
  `render` via `raw_command`.
- File-bridge fallback (no MCP needed):
  `python3 reaperd.py status` health check in `~/Projects/reaper-daemon`,
  `python3 reaperd.py send <json> --wait` for any bridge command.
  Bridge root: `/home/drew/Projects/reaper-daemon` (`inbox/`, `outbox/`).

## Shows
- Two weeklies, same track layout: **Linux Unplugged (LUP)**,
  edited Sunday afternoon; **The Launch**, edited Tuesday
  afternoon/evening.
- Setup trigger: a zip named after show+episode lands in
  `~/Downloads`. Route tracks by filename.
- The Launch differences: AIRMASTER is almost always live (expect
  the Clips track); co-host is **Angela** (not Wes/Brent, though
  they guest sometimes). Angela shares Chris's studio like Wes —
  treat her like Wes (bleed: measure floor, expect a hot trim).
  Stored chain: `Guest/Angela Fisher.RfxChain` exists; prefer a
  freshly measured floor over assumptions.

## Podcast profile (xDarkzx)
`~/.config/opencode/reaper-podcast.toml` includes only: transport, track,
project, item, take, marker, selection, envelope, send, fx, inventory,
analysis, script, chops. MIDI/composition/genre-mix modules are excluded
on purpose. For composition or measured mix moves, use `reaper-daemon`.

## Dialogue prep workflow (podcast)
- ALWAYS auto-trim (split silence) BEFORE any LUFS pass, on every
  non-host track INCLUDING call-in (Caller, Mumble).
  Use headless `MCP Agent/mcp_autotrim.lua` — the stock
  `AutoTrim_SplitRemoveSilence_Tunable.lua` pops a modal dialog and
  can't run unattended.
  Non-host values: threshold -72 dB, min silence 2000 ms,
  min clip 500 ms, pad 1000 ms, edge fade 500 ms. min clip 500 ms
  applies to ALL trims including hosts (set 2026-09-17 per Drew:
  2000 ms was eating sub-2 s utterances — laughs, "yeah"s — on
  TL84 Angela).
- Host tracks get the same treatment LATER, only after running them
  through the `Host Input` chain as take FX, with a DYNAMICALLY
  measured threshold — never a fixed number. Measure the printed
  file's noise floor every time a host is added: full-file `ebur128`
  momentary series → histogram → floor = densest quiet cluster
  (room tone; ignore the -100 bucket of fades/gated tails) →
  threshold ≈ floor + 9–15 dB, in the valley before soft speech.
  Settled formula (LU684, ear-verified): gate OPENS at floor + 18 dB
  and CLOSES at floor + 12 dB (6 dB hysteresis — kills boundary
  chatter; `hysteresis_db` in the autotrim request). Floors measured:
  Chris ~-75, Wes ~-56 (Chris's bleed, +20 dB hotter room), Brent
  -81 (RX de-noise shelf) → trims Chris -57/-63, Wes -38/-44,
  Brent -63/-69.
  Soundboard + call-in stay fixed at -72 always.
- AIRMASTER: measure its noise floor; if real audio sits above the
  floor, create a `Clips` track after Sound FX and put it there —
  otherwise leave the Clips track out entirely. When the Clips track
  exists, treat it like a host for trimming: measured floor +
  hysteresis gate (it always needs a hot threshold).
  Full host chain (set 2026-09-14, proven on LU684-test): LUFS-I
  correct the raw file (cap ±12, peak ceiling -2 — all three hosts
  hit the ceiling raw, so expect peak-limited first gains) →
  `Host Input` (`Podcast/Host Input.RfxChain`, ACM510X1) as TAKE FX →
  `42688` apply-take-FX-as-new-take (mono) ONE file at a time,
  announced, verified per file (NOT glue — 63-min glue renders
  intermittently come out zeroed; apply is proven) → crop to active
  take (40131) → LUFS-I again (ONE uniform gain PER HOST TRACK —
  each host measured independently on its own whole printed file,
  just before its trim; cap ±12, peak ceiling -2) →
  dynamic-threshold trim → stamp that track's SAME gain onto every
  resulting clip in one batch. Hosts keep consistent gain — NO per-clip
  leveling on host tracks (set 2026-09-17 per Drew: per-clip makes
  item gain wander item-to-item). Autotrim resets new items to 0 dB,
  so the uniform gain must land post-trim.
  Brent's take FX adds de-noise first (see exception below).
  Take-FX paste has no MCP-native path: load the chain onto a temp
  track with daemon `add_fx_chain`, copy with
  `MCP Agent/mcp_takefx_copy.lua` (`TrackFX_CopyToTake`, proven
  per-take), delete the temp track. (Chunk-splicing takes is a dead
  end: single-take items carry no `<TAKE` block, and the `.rpp` on
  disk goes stale the moment the live session moves — verify live.)
- Brent exception: background noise — his take FX stack is
  `RX 12 Voice De-noise (iZotope)` FIRST, then the Host Input chain
  (`MCP Agent/mcp_takefx_brent.lua`).
- Then, NON-HOST tracks only, per-clip momentary (`ebur128` M max) LUFS leveling to the
  episode target, gains capped, true-peak ceiling enforced.
  Metric split (set 2026-09-14): clips < 8 s use max momentary (M),
  clips >= 8 s use integrated (I) — 8 s gives the integrated gate
  enough material; below that a single loud 400 ms burst should set
  the level. Target -23, cap gains at ±12 dB, true-peak ceiling -2 dB.
  Measure each clip's source section offline with ffmpeg `ebur128`
  (no renders needed); apply in one `items_apply` batch (undoable).

## Session creation defaults (podcast, all shows)
- Master bus: load `Bus/Master.RfxChain` (Limiter 3 + Loudness Meter)
  with the limiter BYPASSED at start.
- Sidechain (every podcast, not just Linux Unplugged): Hosts bus sends
  to Music and Sound FX sidechain inputs at 0 dB. Music/Sound FX keep
  4 channels for the sidechain pair; their post-fader 0 dB sends back
  to Hosts stay as-is.
- Ruler: `Minutes:Seconds (Minimal)` — never beats for podcast work.
  Fire 43204 (ruler) + 40410 (transport clock) via fixed
  `MCP Agent/mcp_action_run.lua` — user-confirmed working 2026-09-14
  (the old runner passed section-as-command and fired no-ops; fixed
  to `Main_OnCommand(cmd, 0)`). Eyeball-confirm anyway: the ruler
  unit is global live state, not per-project storage, so save+grep
  can't verify it. (.rpp TIMEMODE is the project timebase, unrelated.)
  Run `script_run`s sequentially: parallel runs race on the shared
  extstate result slot and return each other's results.
- Markers: every podcast session gets `Intro` at 00:00:00.
- AIRMASTER source file: check for real clips, but usually empty —
  high noise floor looks like content when it isn't. If empty, ignore
  (don't import).
- Track heights: hosts TALL and uniform; soundboard (music, sound fx,
  clips) + call-in (Caller, Mumble) SHORT and uniform (shorter than
  hosts). All tracks must fit on screen at once, no scrolling.
  Reference (LU684, good example, normalize the near-matches):
  hosts ~262 (observed Chris 274 / Wes 250 / Brent 261),
  small ~81 (observed Music 88 / Sound FX 81 / Mumble 75),
  Hosts folder 0 (default).
- Track colors: Rose Pine MAIN variant, always unique per track.
  Soundboard tracks (music, sound fx, clips, …) as a blue-ish gradient.
  Reference (LU684 + TL84): Music pine (49,116,143),
  Sound FX mid-blue (102,161,179), Clips foam (156,207,216),
  Hosts/buses subtle gray (144,140,170), Chris love (235,111,146),
  Angela rose (235,188,186), Wes iris (196,167,231),
  Brent mauve (215,177,208), Caller gold (246,193,119),
  Mumble dawn-gold (234,157,52). FX-send (receive-only) buses black.
- Heights/ruler need ReaScript (`I_HEIGHTOVERRIDE`, ruler mode) via a
  confirmed `script_run` — neither MCP exposes them directly.
  Heights: `MCP Agent/mcp_track_heights.lua` + request file
  (hosts 262, small 81). Ruler/clock: actions 43204 + 40410 via
  `MCP Agent/mcp_action_run.lua`.

## New-session punch list (podcast, in order)
1. Sample rate: project override 44.1 kHz (`mcp_project_rate.lua`)
   + `pw-metadata -n settings 0 clock.force-rate 44100`. Verify:
   daemon `sample_rate_overridden: true`, saved `.rpp`
   `SAMPLERATE 44100 1 0`.
2. Tracks: Music, Sound FX, Hosts (folder 1), hosts…, call-in last
   (folder -1). Colors (unique, soundboard blue gradient) + folders
   in one pass; verify with `track_get_all`.
3. Master bus: `Bus/Master.RfxChain`, limiter BYPASSED (read back).
4. Import sources (skip AIRMASTER unless its floor-check says clips;
   then add a `Clips` track after Sound FX). `Intro` marker at 0:00.
5. Sidechain: Hosts → Music + Sound FX @ 0 dB to ch 3/4
   (`mcp_sidechain_send.lua`; sets 4ch) — verify dst_channel 2.
6. Heights (hosts 262 / small 81, `mcp_track_heights.lua`, read-back)
   + ruler/clock (43204 + 40410, eyeball).
7. Non-hosts: trim (-72 set) → per-clip LUFS (M<8 s / I≥8 s, ±12 cap,
   -2 dBTP ceiling, one `items_apply`).
8. Hosts, each file: LUFS-I → Host Input take FX (temp-track +
   `mcp_takefx_copy.lua`; Brent adds RX denoise first via
   `mcp_takefx_brent.lua`) → `42688` apply-as-new-take mono (ONE at
   a time, announced, file verified) → crop (40131) → LUFS-I →
   measure floor → trim (open floor+18 / close floor+12).
9. Track FX: batch-load all stored chains (one daemon `batch`),
   read back every track's chain.
10. Save. Teardown when done: rate override off,
    `clock.force-rate 0`.

## Vocal EQ (Pro-Q 4 via MCP) + dial-ins (from agent-notes.md, 2026-09-17)
- Param layout: 24 bands x 23 params (band N base = (N-1)*23) + globals 552+.
  Per band: +0 Used · +1 Enabled · +2 Frequency · +3 Gain · +4 Q · +5 Shape ·
  +6 Slope · +7..+22 dynamics/sidechain (defaults fine).
- WRITE ORDER IS LOAD-BEARING: set `Used` FIRST per band, then ascending
  index order — never Freq/Gain/Q before Used (STATUS_ACCESS_VIOLATION).
- Value math (verified via display readback): Freq v=log10(f/10)/log10(3000)
  (10 Hz-30 kHz) · Gain v=0.5+dB/60 (±30) · Q v=(lnQ+3.688879)/7.377759
  (0.025-40) · Shape step/9 (0 Bell, 1 Low Shelf, 2 Low Cut, 3 High Shelf,
  4 High Cut) · Slope continuous v=dB/60 (0.1 = 6 dB/oct, 0.2 = 12 dB/oct;
  0.0 = no filter!) · Threshold v=(dB+60)/60 · Dynamic Range same ±30 map
  as Gain · Auto Gain global idx 561.
- `fx_get_params` hides unused bands (Used==0) — enable first, then the block
  appears. `fx_scan_params` is BROKEN on this REAPER (nil
  TrackFX_GetParameterStepCount) — calibrate by probe-write + readback.
- Blessed source of truth (2026-09-17, TL84): `Host/Chris Fisher.RfxChain` +
  `Host/Angela Fisher.RfxChain` (ACM70SA → ACM-2SA → Pro-Q 4). Do NOT
  overwrite without explicit say-so.
- LUP684 starting curves (translated from ZL, ear-tuned on edit day):
  Chris: LowCut 50/6dB · Bell 116.5/-2.68/Q1.0 · Bell 372/-0.65/Q1.49 ·
  Bell 1603/-0.41/Q0.97 · HShelf 7520/+0.75/6dB · HighCut 30k/12dB ·
  Dyn Bell 9076/-4dB thr -16.5 · Auto Gain On.
  Wes: LowCut 50/6dB · Bell 120/-1.77 · Bell 1603/-0.76/Q1.71 ·
  HShelf 8038/+0.66/6dB · HighCut 30k/12dB · Dyn Bell 9076/-4dB thr -18.0.
  Brent: LowCut 50/6dB · Bell 145.6/-1.32 · Bell 454/-1.83/Q2.0 ·
  Bell 1599/-0.93/Q0.74 · Bell 2903/-1.12/Q4.05 · HShelf 8000/-1.16/6dB
  (negative = intent) · HighCut 30k/12dB · Dyn Bell 5373/-4dB thr -16.9.
- Pinned pre-migration (2026-09-17, Fedora): `xdarkzx-reaper-mcp 0.7.1`
  via pipx, Python 3.14.7.

## Rules learned
- Both servers push to the RUNNING session. Never edit the `.rpp` file on
  disk while REAPER is open — that was the old close-without-saving
  workaround and it is obsolete. Mutations are undoable (Ctrl+Z /
  `project_undo`); daemon batches are one undo block.
- Save: gates are open (`audio_writes`, `project_save`, `preference_writes`
  all true as of 2026-09-14). `project_save` (xDarkzx) or `save_project`
  (daemon) writes the open `.rpp` live. Use `project_backup` before
  destructive work.
- Renders inherit REAPER's Render dialog. xDarkzx `project_export_audio`
  has no channels param. For mono/stem tweaks: daemon
  `get_render_settings` → `set_render_settings` (check `applied` read-back)
  → `render`, then restore prior settings. Render settings live outside
  undo — always read back and restore.
- Sample rate: set 44.1 kHz WITH override at session setup
  (`MCP Agent/mcp_project_rate.lua` — without the override flag REAPER
  follows the audio device, e.g. 48 kHz, and renders come out at the
  wrong rate). ALSO force the PipeWire device clock:
  `pw-metadata -n settings 0 clock.force-rate 44100` (project
  override alone doesn't move the device). Set back to default
  (override off, `clock.force-rate 0`) at teardown.
- Glue/apply/render actions pop a modal progress dialog that steals
  focus — announce every render up front ("hands off for ~1 min") and
  never touch anything mid-render. A cancelled dialog writes partial/
  zeroed files: if a render measures silent, check for cancellation
  BEFORE theorizing about signal paths (learned 2026-09-14).
- Long renders (>30 s) outlast xDarkzx's `script_run` timeout AND stall
  the daemon heartbeat — both go quiet while REAPER is still rendering.
  Watch the output file grow (`ls -la`) instead of assuming death; the
  bridge comes back when the render lands.
- Item indices in xDarkzx RESPONSES are unreliable after edits — always
  re-read (`item_get_all` per track) and match by track+position+source
  before acting. Prefer name/GUID addressing (daemon side) for deletes.
- Verify live state with `get_status` + `get_context` (daemon) and
  `project_get_overview` (xDarkzx) — both must agree on project name,
  track and item counts before mutating.
- Last verified 2026-09-14: `Linux Unplugged 684.RPP`, 7 tracks, 425 items,
  render target FLAC stereo `$project (Ads)`.
- The Launch render set (2026-09-17, TL84): stems for Clips/Chris/Angela/
  Caller to `Stems/<project> - <track>.flac` (pattern `$project - $track`,
  FLAC stereo); master to `Render/<project>.flac` + `Render/<project>.mp3`
  (full show, no ad/premium split); markers to `Render/<project>.txt` as
  `HH:MM:SS Name` lines. Dialog also writes MP3 stem sidecars + a
  `.flac.mp3`-named master sidecar (secondary format) — rename or drop.
  Stems need FLAC ONLY: drop the MP3 sidecars after the FLACs verify
  (set 2026-09-17 per Drew: TL84 stems shipped 4 unneeded MP3s).
- Caller distrust rule (from agent-notes.md): full-length `Calls.flac`-style
  files have delivered silent — do not trust; caller audio lives in the
  Soundboard mix. Extraction: region after the mid-episode song break
  (Bumper-Song-Bumper) to segment end; split on LARGE gaps only (>= 5 s;
  speech pauses are 0.5-0.9 s), 0.1 s handles, downmix mono, -23 LUFS-I
  (TP -2, LRA 7), place at true timeline positions.
- Archive method (lossless, keeps handles): integer WAV -> FLAC
  (PCM-verified via framemd5), FLAC -> copy, 32-bit float WAV -> keep WAV.
  Never bounce. Rewrite RPP `FILE "Media/..."` lines only; RPP otherwise
  byte-identical. **When a FILE line changes container (e.g. `.wav` ->
  `.flac`), the enclosing `<SOURCE>` type MUST change with it (`<SOURCE
  WAVE>` -> `<SOURCE FLAC`) — REAPER dispatches its decoder on the SOURCE
  type, not the file contents, so a stale WAVE-over-FLAC block renders as an
  empty item even though the audio is fine (hit 5 archives 2026-09-19:
  LUP 683×2, 684, TL 83/84; fixed + manifests refreshed).**
  Include ONLY RPP-referenced audio. Write
  `manifest-sha256.txt` (RPP + Media).
