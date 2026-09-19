# ReaSonus Native

Packaging for [ReaSonus Native](https://github.com/navelpluisje/Reasonus-Native),
a REAPER control-surface extension for PreSonus FaderPort devices. Used here
with an **ioStation 24c** (FaderPort V2 family).

## Files

| file | purpose |
|---|---|
| `default.nix` | derivation; builds upstream from source |
| `module.nix` | links the built artifacts into REAPER's resource dir |
| `fader-calibration.py` | patches the fader taper for the ioStation 24c |
| `calibrate.py` | *optional* instrumentation for measuring a device's fader |

## Build notes

Upstream's CMake pulls five dependencies over the network via `FetchContent`
(WDL, reaper-sdk, GSL, mINI, fmt) and downloads a ReaImGui header at configure
time. The Nix sandbox has no network, so all six are pinned in `default.nix`
and pre-populated into `lib/` in `postPatch`.

Keeping upstream's `lib/<name>` layout matters: `CMakeLists.txt` creates the
symlink `lib/reaper-sdk/WDL -> lib/WDL/WDL`, and `FindWDL.cmake` /
`FindSWELL.cmake` search under `lib/WDL`. Pointing `SOURCE_DIR` at store paths
directly breaks that step.

Linux needs the flags from upstream issue #29:

```
-include cstdlib -include cmath -include cstring -include cstdio
-DSWELL_DLG_WS_DEFAULT_SCALING=0
```

These are set in `preConfigure` rather than `cmakeFlags`, because the cmake
hook word-splits `cmakeFlags` and would mangle the space-separated list.
`SWELL_DLG_WS_DEFAULT_SCALING=0` means dialogs do not scale on HiDPI displays.

## Fader calibration

### The problem

ReaSonus maps the device's 14-bit fader value onto REAPER's volume range by
treating the raw value as a fraction of full travel:

```c
// fader -> REAPER
pos = raw * 1000.0 / 16383.0;
return DB2VAL(SLIDER2DB(pos));

// REAPER -> fader
normalized = DB2SLIDER(VAL2DB(vol)) / 1000.0;
```

That assumes the device's unity position sits at the top of its travel. On an
ioStation 24c it does not: unity sits at raw **12595** (76.9% of travel), while
REAPER's 0 dB corresponds to raw **11734**. Physical unity therefore reads about
**+2.4 dB** in REAPER.

### The fix

`fader-calibration.py` remaps the raw value onto the range the existing math
expects, pivoting at unity so the endpoints are preserved:

```
raw <= 12595:  raw * 11734 / 12595
raw >  12595:  11734 + (raw - 12595) * (16383 - 11734) / (16383 - 12595)
```

It is applied in **both** directions. `int14ToVol` and `volToNormalized` must
remain exact inverses, or the motorized fader fights REAPER when the track
selection changes.

### Measuring a different device

The constants above are specific to the ioStation 24c. To calibrate another
device, build the instrumented variant and sweep the fader:

```sh
nix build --impure --expr \
  'let f = builtins.getFlake (toString ./.);
   in f.packages.x86_64-linux.reasonus-native.override { calibrate = true; }'
```

Install the resulting `.so` into `~/.config/reaper-flake/UserPlugins/`, start
REAPER, and move the fader slowly through its full travel. Every raw value and
the volume REAPER derives from it is appended to `/tmp/reasonus-cal.log`:

```
raw=12595 msb=98 lsb=51 vol=1.315408
```

From the log you need two numbers:

- **`REAPER_UNITY`** — the raw value where `vol` crosses `1.0` (interpolate
  between the bracketing samples).
- **`DEVICE_UNITY`** — the raw value at the device's physical unity position.

For `DEVICE_UNITY`, note that the ioStation has **no physical detent**, so it
has to be judged by eye. The curve near unity is shallow (~0.0004 dB per raw
count), so this is not very sensitive — being off by 50 counts is only ~0.02 dB.

Then update the constants in `fader-calibration.py` and rebuild.

The log is opened in `"w"` mode, so it resets each time REAPER starts. Copy a
run aside before restarting if you want to keep it.
