# REAPER on a dedicated Xwayland server with Openbox

**Problem**: REAPER under xwayland-satellite has no window manager, so its
floating FX/plugin windows are unmanageable.

**Solution**: Run REAPER on a dedicated Xwayland server (`xwayland-run`) with
Openbox as the window manager. Openbox parents the transient windows so they
behave. Cleanup is automatic: `xwayland-run` kills its process group
(Openbox + X server) when REAPER exits.

## Files

- **Module**: `proaudio/reaper-xwayland/default.nix` — Home Manager module
- **Launch script**: installed to `~/.nix-profile/bin/reaper-xwayland.sh`
  - Spawns Openbox (dedicated config) → REAPER under one `xwayland-run`
  - Trap on the Openbox PID as a cleanup fallback
- **Desktop entry**: `~/.local/share/applications/reaper-xwayland.desktop` —
  searchable in the Noctalia launcher (`Mod+Space`)
- **Openbox config**: `~/.config/reaper-openbox/rc.xml` — single workspace,
  click-focus, centered windows, no Alt+mouse bindings (move = titlebar drag,
  resize = edge drag), main window opens maximized, dialogs stay floating
- **Theme**: `Reaper` in `~/.themes/Reaper/` (rose-pine moon, Inter Variable
  titlebars, dark 1px borders)

## Usage

Open the launcher (`Mod+Space`) and search for "REAPER (Xwayland)", or run from terminal:

```bash
reaper-xwayland.sh
```

## Dependencies

- `xwayland-run` — system package
- `openbox` — installed by the module
- `reaper` — already installed
