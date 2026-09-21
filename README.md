# nixconfig

Declarative NixOS setup for my machines. Shared system + home config with
per-host overlays, Noctalia desktop on Umbriel (primary) and Niri.

## Hosts

| Host | Role | GPU | Status |
| ---- | ---- | --- | ------ |
| `shephard` | daily driver | Intel | active |
| `blackstar` | gaming | RTX 3080 (open + latest) | pre-staged, needs `hardware-configuration.nix` |

## Layout

- `flake.nix` — `mkHost` helper, inputs, binary caches.
- `configuration.nix` / `home-common.nix` — shared system + home config.
- `hosts/<name>/{host.nix, hardware-configuration.nix, home.nix}` — per-host.
- `modules/nvidia.nix` — shared Nvidia setup.
- `umbriel.nix`, `noctalia.nix` — compositor/shell settings.
- `MEMORY.md` — decisions and gotchas for future sessions.

## Usage

```bash
nh os switch            # rebuild + activate (hostname picks the config)
nh os boot              # activate on next reboot
```

New machine: generate its hardware config, drop it in `hosts/<name>/`,
uncomment its `mkHost` line in `flake.nix`, `nh os switch --hostname <name>`
(or run on the machine directly).
