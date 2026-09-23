# REAPER + Xephyr + Fluxbox (nested X11 audio setup)

**Problem**: REAPER has issues with XWayland-satellite and Wayland-native libswell.

**Solution**: Run REAPER inside a nested X11 server (Xephyr) with Fluxbox as the window manager. This gives REAPER a pure X11 environment while staying inside an Umbriel window.

## Components

| Component | Role |
|---|---|
| **Xephyr** | Nested X11 server (`xorg-server` package). Runs as a window inside Umbriel. |
| **Fluxbox** | Featherweight stacking WM (already installed). Uses Alt (Mod1) for window ops — no Super/Ctrl/F-key conflicts with REAPER. |
| **REAPER** | Runs natively inside the nested X11 session. |

## Files

- **Module**: `proaudio/reaper-xephyr/default.nix` — Home Manager module that enables the setup
- **Launch script**: installed to `~/.nix-profile/bin/reaper-xephyr.sh`
  - Resolves Xephyr from nixpkgs if not in PATH
  - Spawns Xephyr → Fluxbox (dedicated config) → REAPER
  - Cleans up on REAPER exit
  - Env vars: `DISPLAY_NUM` (default 1), `WIDTH` (default 1920), `HEIGHT` (default 1080)
- **Desktop entry**: `~/.local/share/applications/reaper-xephyr.desktop` — searchable in the Noctalia launcher (`Mod+Space`)
- **Fluxbox config**: deployed to `~/.config/umbriel/fluxbox-reaper/`
  - `init` — ClickFocus; no toolbar
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

Open the launcher (`Mod+Space`) and search for "REAPER (Xephyr)", or run from terminal:

```bash
reaper-xephyr.sh
```

To adjust resolution:

```bash
DISPLAY_NUM=2 WIDTH=2560 HEIGHT=1440 reaper-xephyr.sh
```

## Dependencies

- `xorg-server` (for Xephyr) — install via `nix profile install nixpkgs#xorg-server`
- `xorg.xdpyinfo` (for readiness check, optional fallback)
- `fluxbox` — already installed
- `reaper` — already installed