# nixconfig durable memory

## Layout
- `flake.nix` — `mkHost` helper; `nixosConfigurations.shephard` (+ commented `blackstar`).
- `configuration.nix` — shared system config. `home-common.nix` — shared home.
- `hosts/<name>/{host.nix, hardware-configuration.nix, home.nix}` — per-host.
- `modules/nvidia.nix` — open + latest branch (RTX 3080 on blackstar).
- Compositor settings split out: `umbriel.nix`, `niri.nix` (imported by home-common).

## Key decisions
- **yabridge is custom**: `yabridge-dev`/`yabridgectl-dev` = nixpkgs package overridden to dev
  commit `b580a9f` (needed for Wine 11). Pinned; never auto-updates. Stable fallback is
  plain `yabridge`/`yabridgectl`. NIX_PROFILES patch re-applied from nixpkgs (required
  for chainloader lib lookup); other nixpkgs patches dropped (don't apply to dev tree).
- **Bottles removed again** (unreliable; second try 2026-09-18 with Flatpak +
  wineloader also dropped). Plain system Wine (`wineWow64Packages.staging`) +
  winetricks, no `WINELOADER` set. Bottle prefix data left on disk under
  `~/.var` if ever needed again.
- **yabridge GUI crash is systemic**: `get_root_window` BadWindow terminate under
  xwayland-satellite (Umbriel). Works headless/DSP-side; Carla dies the same way.
  Niri (own Xwayland) is the test bed. Candidate upstream issue at robbert-vdh/yabridge.
- **DXVK off for FabFilter/Analog Obsession type plugins** (black GUI with DXVK on).
- **Reaper extensions** (SWS/ReaPack) must be symlinked into `~/.config/REAPER/` via
  `xdg.configFile` — packages alone are invisible to Reaper.
- **GTK headerbar buttons**: `gtk-decoration-layout=":"` + dconf `button-layout=""`.
- **Pro audio baseline**: `@audio` memlock unlimited / rtprio 95 / nice -19, rtkit,
  PipeWire JACK, ntsync module. musnix not yet added (only if xruns persist).
- **Zed is native** (`zed-editor` via `programs.zed-editor` + extensions `nix`, `toml`);
  FHS dropped. Toolchains via `extraPackages` + home packages.
- **opencode is upstream**, not nixpkgs: both stable (1.15.x) and unstable (1.18.30)
  builds are unusable (1.18.30 crashes resolving any model, `TypeError err_*` on every
  prompt). Installed via `https://opencode.ai/install` to `~/.opencode/bin` (on PATH via
  `home.sessionPath`, autoupdates itself). Zen provider disabled in
  `~/.config/opencode/opencode.jsonc` (no payment method on workspace);
  `small_model` = free `openrouter/inclusionai/ling-3.0-flash-vl:free`.
- **Pro audio** lives in `proaudio/` (all hosts via home-common):
  `proaudio/default.nix` = REAPER + SWS/ReaPack extensions;
  `proaudio/plugins/` = GitHub plugins (one file per plugin) + nixpkgs
  plugin packages. GitHub derivations repackage release assets into
  `$out/<format>` + `passthru.formats`, flake `packages` exposes them
  (one line per plugin), `proaudio/plugins/default.nix` symlinks each format
  to `~/.<format>/github/<pname>` and adds standalones to PATH. Updates:
  single-src files via `nix-update <pname> --flake`; everything (incl.
  multi-asset brummer files and prefixed-tag dusk monorepo) via
  `python3 proaudio/plugins/update.py [--all | <file>...]` (dusk files carry
  `# update-tag-prefix: <prefix>`).
- **nh** is the rebuild frontend: `nh os switch` (hostname → flake attr). Weekly GC.
- **Proton Pass SSH**: binary is `pass-cli` (not `proton-pass`); socket pinned to
  `~/.ssh/proton-pass-agent.sock` on both service (`--socket-path %h/...`) and session.
- **Flatpak theming**: adw-gtk3-dark Flatpak theme + ro `xdg-config/gtk-{3,4}.0` overrides;
  Noctalia GTK templates (`gtk3`, `gtk4`, `niri`) enabled.
- blackstar (Nvidia 3080) not yet online: needs its `hardware-configuration.nix`, then
  uncomment its `mkHost` line. Gets Steam/Gamemode/Heroic/ProtonPlus/Protontricks/
  Gamescope/MangoHud automatically.

## Workflows
- Validate: `nixos-rebuild build --flake .#shephard` (or detached for long builds).
- Switch: `nh os switch`. Validate Niri KDL: `niri validate --config <file>`.
- `yabridgectl sync` after Wine/plugin changes; Reaper VST paths may need store lib dirs added.
