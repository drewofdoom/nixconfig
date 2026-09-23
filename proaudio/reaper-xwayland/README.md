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

## Dependencies

- `xwayland-run` — system package
- `fluxbox` — already installed
- `reaper` — already installed
