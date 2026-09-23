# REAPER on a dedicated Xwayland server with a lightweight WM

**Problem**: REAPER under xwayland-satellite has no window manager, so its
floating FX/plugin windows are unmanageable.

**Solution**: Run REAPER on a dedicated Xwayland server (`xwayland-run`) with
a real WM (Fluxbox by default, Openbox optional). The WM parents the
transient windows so they behave. Cleanup is automatic: `xwayland-run` kills
its process group (WM + X server) when REAPER exits.

## Files

- **Module**: `proaudio/reaper-xwayland/default.nix` — Home Manager module
- **Launch script**: installed to `~/.nix-profile/bin/reaper-xwayland.sh`
  - `REAPER_WM` selects the WM: `fluxbox` (default) or `openbox`
  - Spawns WM → REAPER under one `xwayland-run`, trap as cleanup fallback
- **Desktop entries**: `reaper-xwayland.desktop` (Fluxbox) and
  `reaper-xwayland-openbox.desktop` (Openbox) — searchable in the Noctalia
  launcher (`Mod+Space`)
- **Fluxbox config**: deployed to `~/.fluxbox/` (upstream default location)
- **Openbox config**: `~/.config/reaper-openbox/rc.xml` + `Reaper` theme in
  `~/.themes/Reaper/` (rose-pine moon, Inter Variable titlebars, dark
  1px borders, centered windows, no Alt+mouse bindings)
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
