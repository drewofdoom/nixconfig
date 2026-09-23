# REAPER on a dedicated Xwayland server with Fluxbox

**Problem**: REAPER under xwayland-satellite has no window manager, so its
floating FX/plugin windows are unmanageable.

**Solution**: Run REAPER on a dedicated Xwayland server (`xwayland-run`) with
Fluxbox as the window manager. Fluxbox parents the transient windows so they
appear as regular Umbriel windows. Cleanup is automatic: `xwayland-run` kills
its process group (Fluxbox + X server) when REAPER exits.

## Files

- **Module**: `proaudio/reaper-xwayland/default.nix` — Home Manager module
- **Launch script**: installed to `~/.nix-profile/bin/reaper-xwayland.sh`
  - Spawns Fluxbox (dedicated config) → REAPER under one `xwayland-run`
  - Trap on the Fluxbox PID as a cleanup fallback
- **Desktop entry**: `~/.local/share/applications/reaper-xwayland.desktop` — searchable in the Noctalia launcher (`Mod+Space`)
- **Fluxbox config**: deployed to `~/.fluxbox/` (upstream default location)
  - `init` — ClickFocus; no toolbar/slit
  - `keys` — Alt+drag to move, Alt+right-drag to resize, Alt+Tab to cycle, Alt+F4 to close, Alt+F2 to run
  - `menu` — REAPER, xterm, Run...
  - `windowmenu` — standard window ops
  - `apps` — REAPER starts maximized
  - `style` — matches Noctalia colorscheme (#26233a/#ebbcba/#e0def4)

## Key design decisions

- **No Super (Mod4)** in Fluxbox keys — Umbriel owns Super globally.
- **No Ctrl bindings** in Fluxbox keys — REAPER uses Ctrl heavily.
- **No F-key bindings** except F2/F4 — REAPER uses F-keys for actions.
- **Alt+drag** for window move/resize — doesn't conflict with REAPER shortcuts.
- **ClickFocus** — REAPER expects click-to-focus behavior.

## Usage

Open the launcher (`Mod+Space`) and search for "REAPER (Xwayland)", or run from terminal:

```bash
reaper-xwayland.sh
```

### Input auto-cabling (optional)

WirePlumber likes to cable the default mic into REAPER's inputs, and links
vanish on hotplug/restart. The bundled `reaper-autolink.sh` watcher keeps
your interface cabled to `REAPER:in1/in2` for the whole session:

```bash
REAPER_INPUT_MATCH=ioStation reaper-xwayland.sh
```

`REAPER_INPUT_MATCH` is a substring of the device's PipeWire port name.
Exclusive mode (default) also evicts non-device links into REAPER's inputs;
`REAPER_INPUT_EXCLUSIVE=0` keeps them (multi-source recording).
Standalone one-shot reconcile: `REAPER_AUTOLINK_ONCE=1 reaper-autolink.sh`.

### Low-latency tracking (optional)

```bash
REAPER_LOWLATENCY=1 reaper-xwayland.sh            # 128-sample quantum
REAPER_LOWLATENCY=1 REAPER_QUANTUM=256/48000 reaper-xwayland.sh
```

Sets `PIPEWIRE_LATENCY` for the session only. Leave unset for mixing
(default quantum). REAPER's title bar shows the live buffer/latency —
confirm it dropped before tracking.

## Dependencies

- `xwayland-run` — system package
- `fluxbox` — already installed
- `reaper` — already installed
