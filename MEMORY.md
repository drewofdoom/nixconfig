# nixconfig durable memory

## Layout
- `flake.nix` — `mkHost` helper; `nixosConfigurations.shephard` and `blackstar`.
- `system/` — shared NixOS modules: `core` (boot/nix/user), `desktop`
  (umbriel/noctalia/greeter), `hardware` (graphics/audio/polkit), `services`
  (printing/flatpak/gvfs), `nvidia`.
- `home/` — shared Home Manager modules: `shell`, `theme`, `apps`, `wine`
  (wine/yabridge), `flatpak`, `ssh`, `misc`, `desktop/` (umbriel/noctalia).
- `hosts/<name>/{host.nix, hardware-configuration.nix, home.nix}` — per-host.
- `proaudio/` — REAPER + plugins (all hosts via home).

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
  Niri also uses xwayland-satellite (not its own Xwayland) but its smithay-based
  implementation handles X11 differently than Umbriel's wlroots-based one — Niri
  was the test bed for whether the crash is compositor-specific. Candidate upstream
  issue at robbert-vdh/yabridge. **Niri has been removed from nixconfig**; user is
  staying on Umbriel and accepting xwayland-satellite's current limitations.
- **DXVK off for FabFilter/Analog Obsession type plugins** (black GUI with DXVK on).
- **REAPER is declarative via reaper-flake** (input `reaper-flake`,
  github:9Prestidigitator/reaper-flake, `inputs.nixpkgs.follows = "nixpkgs"`).
  `proaudio/default.nix` imports its Home Manager module and sets
  `programs.reaper`: native-Wayland SWELL (`experimental.swell-wayland.enable`),
  `packages` (freetype/libpng/zlib/fontconfig/libepoxy/gtk3/cairo/glib) for
  ReaImGui-style dlopen deps, SWS, and ReaPack with ReaImGui + js_ReaScriptAPI
  declared. The flake ships its own REAPER 7.80, SWS, and a **patched ReaPack
  1.2.6** (managed-package API: `ReaPack_ExportState`/`QueuePackage`/`IsBusy`)
  — the old nixpkgs `reaper`/`reaper-{sws,reapack}-extension` symlinks are gone.
  Resource dir is `~/.config/reaper-flake` (not `~/.config/REAPER`); activation
  refuses to run while REAPER is open. No FHS env — the wrapper's
  `LD_LIBRARY_PATH` is the ReaImGui fix.
- **REAPER runs under Niri, not Umbriel** (2026-09-20): swell-wayland's bundled
  Xwayland bridge starts ok but degrades mid-session, and Umbriel's
  xwayland-satellite black-screens yabridge windows — so
  `experimental.swell-wayland.enable = false` (stock X11 SWELL) and Niri
  re-enabled (`programs.niri.enable`, `./niri.nix` import back on) for editing;
  greeter default stays Umbriel. Earlier DISPLAY-pin attempts (desktop Exec
  override, `programs.reaper.package` wrapper) both failed and were reverted.
  **Niri has since been removed from nixconfig entirely. User is staying on Umbriel
  and not pursuing swell-wayland or other workarounds — just accepting satellite's
  current limitations and waiting for upstream improvement.**
- **REAPER MCPs re-wired declaratively** (2026-09-19) after the reaper-flake
  move: `proaudio/reaper-mcp.nix` packages xdarkzx `reaper-mcp` 0.8.2 from
  PyPI (with [analysis] extras; `pyloudnorm` built alongside since nixpkgs
  26.05 lacks it) plus the matching `reaper_mcp_server.lua` (GitHub tag
  v0.8.2, updated 2026-09-24). Both bridges load via flake-native mechanisms — lua files through
  `programs.reaper.resourceFiles.files`, startup via additive
  `programs.reaper.lineFiles.files."Scripts/__startup.lua"` (coexists with the
  flake's ReaPack/SWS hooks; never hand-edit `__startup.lua`). Daemon bridge
  lua is vendored in `proaudio/reaper-lua/` (pure eval forbids absolute
  paths — re-copy from `~/Projects/reaper-daemon/bridge/` after bridge
  changes; currently v3.22.1). opencode client config, podcast profile, and
  `REAPER.md` memory are Nix-managed (`proaudio/opencode/`, deployed to
  `~/.config/opencode/`). The old blackstar wiring
  (pipx install, `REAPER/Scripts/__startup.lua` marker blocks) is gone.
- **ReaSonus Native** (`proaudio/reasonus-native/`, flake package
  `reasonus-native`): control-surface extension for the PreSonus **ioStation
  24c** (FaderPort V2 family). Built from source; upstream's CMake pulls WDL /
  reaper-sdk / GSL / mINI / fmt over the network via FetchContent, so all five
  are pinned and pre-populated into `lib/` in `postPatch` (the `lib/<name>`
  layout matters — CMakeLists symlinks `lib/reaper-sdk/WDL -> lib/WDL/WDL`).
  Linux needs the issue-#29 flags (`-include cstdlib -include cmath -include
  cstring -include cstdio -DSWELL_DLG_WS_DEFAULT_SCALING=0`), set via
  `preConfigure` because `cmakeFlags` is word-split. `module.nix` links the
  `.so` into the resource dir; **`en-US.ini` is copied, not symlinked** — the
  extension does `std::filesystem::copy` onto it at startup and then writes
  back, which fails on a read-only store symlink.
- **ioStation 24c fader calibration** (2026-09-19): the device's unity is at
  raw **12595** (76.9% of travel), not at the top, so ReaSonus's
  `raw * 1000 / 16383` mapping made physical unity read **+2.4 dB**. REAPER's
  0 dB corresponds to raw **11734**. `fader-calibration.py` remaps raw onto the
  expected range pivoting at unity, applied in **both** `int14ToVol` and
  `volToNormalized` (they must stay exact inverses or the motorized fader
  fights REAPER). Measured by a full fader sweep logging raw+vol to
  `/tmp/reasonus-cal.log` via the `calibrate = true` build variant
  (`calibrate.py`); 445 distinct values, monotonic, endpoints 0/16383 intact.
  Note the ioStation has **no physical detent** — unity was eyeballed, so the
  constant is good to ~0.02 dB, not exact.
- **GTK headerbar buttons**: `gtk-decoration-layout=":"` + dconf `button-layout=""`.
- **Pro audio baseline**: `@audio` memlock unlimited / rtprio 95 / nice -19, rtkit,
  PipeWire JACK, ntsync module. musnix not yet added (only if xruns persist).
- **Zed is native** (`zed-editor` via `programs.zed-editor` + extensions `nix`, `toml`);
  FHS dropped. Toolchains via `extraPackages` + home packages.
- **opencode is upstream**, not nixpkgs: both stable (1.15.x) and unstable
  (1.18.30) builds were unusable (1.18.30 crashes resolving any model,
  `TypeError err_*` on every prompt). Installed via
  `https://opencode.ai/install` to `~/.opencode/bin` (on PATH via
  `home.sessionPath`, autoupdates itself). Zen provider disabled in
  `~/.config/opencode/opencode.jsonc` (no payment method on workspace).
  Model override previously pinned to
  `openrouter/inclusionai/ling-3.0-flash-vl:free` on blackstar — removed
  since the issue was the package, not the model.
- **Pro audio** lives in `proaudio/` (all hosts via home-common):
  `proaudio/default.nix` = REAPER via reaper-flake (see above);
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
  Noctalia GTK templates (`gtk3`, `gtk4`) enabled.
- blackstar (Nvidia 3080) is online. Gets Steam/Gamemode/Heroic/ProtonPlus/
  Protontricks/Gamescope/MangoHud automatically.
- **VA-API needs no manual wiring**: `hardware.nvidia.videoAcceleration` defaults to
  `true` in nixpkgs and already pulls `nvidia-vaapi-driver` into the graphics driver
  set. Do NOT add `nvidia-vaapi-driver` to `hardware.graphics.extraPackages` -- it is
  redundant. Verify with `nix shell nixpkgs#libva-utils -c vainfo` (expect
  "VA-API NVDEC driver [direct backend]").
- **REAPER desktop entry pins `DISPLAY=:10`** (`xdg.desktopEntries.reaper` in
  `proaudio/default.nix`, `exec = "env DISPLAY=:10 reaper %F"`). Umbriel's
  xwayland-satellite owns `:0`; inheriting it routes REAPER's X11 plugin windows
  through satellite -- the black-screen yabridge bug. swell-wayland spawns its own
  plain `Xwayland :10 -rootless`, so `:10` is the safe display. `GDK_BACKEND=wayland`
  is already set session-wide and is NOT repeated in the entry.
- **blackstar on Zen + unstable NVIDIA** (2026-09-22): `boot.kernelPackages =
  pkgs.linuxPackages_zen` (7.2.6) + unstable's `linuxPackages_zen` 615 driver.
  Stable's 595 doesn't compile against 7.x (gcc-15 `strncpy` error); both
  channels carry Zen 7.2.6 so the module ABI check passes. Fallback if Zen
  moves without the driver: `pkgs.linuxPackages` (6.12 LTS) +
  `nvidiaPackages.stable`.
- **blackstar kernel/VM tuning** (`hosts/blackstar/host.nix`): `nowatchdog` +
  `preempt=full` (kernel is PREEMPT_DYNAMIC), `vm.swappiness=180` +
  `vm.page-cluster=0` (zram-appropriate), `bbr` + `fq`, `systemd-boot.configurationLimit=10`.
  Gamemode sets `desiredgov=performance` but deliberately leaves `defaultgov` unset so
  exit restores the *current* state -- keeps the Noctalia power toggle (which drives
  power-profiles-daemon) authoritative when no game runs.

## Workflows
- Validate: `nixos-rebuild build --flake .#shephard` (or detached for long builds).
- Switch: `nh os switch`.
- `yabridgectl sync` after Wine/plugin changes; Reaper VST paths may need store lib dirs added.
