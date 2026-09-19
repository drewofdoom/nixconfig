# Applies the ioStation 24c fader calibration to ReaSonus Native.
#
# Why
# ---
# ReaSonus maps the device's 14-bit fader value onto REAPER's volume range by
# treating the raw value as a fraction of full travel:
#
#   int14ToVol:      pos = raw * 1000 / 16383;  return DB2VAL(SLIDER2DB(pos))
#   volToNormalized: normalized = DB2SLIDER(VAL2DB(vol)) / 1000
#
# That assumes the device's unity position sits at the top of its travel. On an
# ioStation 24c it does not: unity sits at raw 12595 (76.9% of travel), while
# REAPER's 0 dB corresponds to raw 11734. The result is that the physical unity
# position reads about +2.4 dB in REAPER.
#
# Measured on hardware (see README.md for the method): a full sweep of the
# fader logged 445 distinct raw values spanning 0..16383, monotonic, with
# unity crossing vol=1.0 at raw 11734.
#
# Fix
# ---
# Remap the device's raw value onto the range the existing math expects, with
# unity as the pivot so the endpoints are preserved:
#
#   raw <= 12595:  raw * 11734 / 12595
#   raw >  12595:  11734 + (raw - 12595) * (16383 - 11734) / (16383 - 12595)
#
# Applied in both directions (int14ToVol and volToNormalized) so the motorized
# fader tracks REAPER without fighting it. The two functions are exact
# inverses, so the round trip is lossless.
#
# Run from the source root: python3 fader-calibration.py
import pathlib
import sys

UTILS = pathlib.Path("src/shared/csurf_utils.cpp")

# Device raw value at the physical unity position, and the raw value that the
# unmodified math maps to 0.00 dB.
DEVICE_UNITY = 12595
REAPER_UNITY = 11734
MAX_RAW = 16383

HELPERS = f"""
// --- ioStation 24c fader calibration -------------------------------------
// The device's unity position is not at the top of its travel, so raw values
// are remapped onto the range the volume math below expects. See
// fader-calibration.py for the measurements behind these constants.
namespace {{
constexpr int kDeviceUnity = {DEVICE_UNITY};
constexpr int kReaperUnity = {REAPER_UNITY};
constexpr int kMaxRaw = {MAX_RAW};

// Device raw -> the value the volume math expects.
int CalibrateFaderRaw(const int raw) {{
    if (raw <= 0) return 0;
    if (raw >= kMaxRaw) return kMaxRaw;
    if (raw <= kDeviceUnity) {{
        return raw * kReaperUnity / kDeviceUnity;
    }}
    return kReaperUnity +
           (raw - kDeviceUnity) * (kMaxRaw - kReaperUnity) / (kMaxRaw - kDeviceUnity);
}}

// Inverse of CalibrateFaderRaw, for driving the motorized fader.
int UncalibrateFaderRaw(const int raw) {{
    if (raw <= 0) return 0;
    if (raw >= kMaxRaw) return kMaxRaw;
    if (raw <= kReaperUnity) {{
        return raw * kDeviceUnity / kReaperUnity;
    }}
    return kDeviceUnity +
           (raw - kReaperUnity) * (kMaxRaw - kDeviceUnity) / (kMaxRaw - kReaperUnity);
}}
}} // namespace
"""

# int14ToVol: fader -> REAPER. Remap before the existing conversion.
INT14_OLD = """double int14ToVol(const unsigned char msb, const unsigned char lsb) {
    const int val = lsb | msb << 7;
    double pos = static_cast<double>(val) * 1000.0 / 16383.0;
    pos = SLIDER2DB(pos);

    return DB2VAL(pos);
}"""

INT14_NEW = """double int14ToVol(const unsigned char msb, const unsigned char lsb) {
    const int val = CalibrateFaderRaw(lsb | msb << 7);
    double pos = static_cast<double>(val) * 1000.0 / 16383.0;
    pos = SLIDER2DB(pos);

    return DB2VAL(pos);
}"""

# volToNormalized: REAPER -> fader. Remap after the existing conversion.
VOL_OLD = """double volToNormalized(const double vol) {
    const double normalized_volume = DB2SLIDER(VAL2DB(vol)) / 1000.0;
    if (normalized_volume < 0.0) {
        return 0.0;
    }

    if (normalized_volume > 1.0) {
        return 1.0;
    }

    return normalized_volume;
}"""

VOL_NEW = """double volToNormalized(const double vol) {
    const double normalized_volume = DB2SLIDER(VAL2DB(vol)) / 1000.0;
    if (normalized_volume < 0.0) {
        return 0.0;
    }

    if (normalized_volume > 1.0) {
        return 1.0;
    }

    return static_cast<double>(UncalibrateFaderRaw(
               static_cast<int>(normalized_volume * 16383.0))) / 16383.0;
}"""


def patch(path: pathlib.Path, old: str, new: str, label: str) -> bool:
    source = path.read_text()
    if new in source:
        print(f"fader-calibration.py: {label} already applied")
        return True
    if old not in source:
        print(f"fader-calibration.py: {label} pattern not found", file=sys.stderr)
        return False
    path.write_text(source.replace(old, new, 1))
    print(f"fader-calibration.py: patched {label}")
    return True


def main() -> int:
    source = UTILS.read_text()

    # Insert the helpers just before volToNormalized's definition.
    if "CalibrateFaderRaw" not in source:
        anchor = "double volToNormalized(const double vol) {"
        if anchor not in source:
            print("fader-calibration.py: helper anchor not found", file=sys.stderr)
            return 1
        source = source.replace(anchor, HELPERS.lstrip() + "\n" + anchor, 1)
        UTILS.write_text(source)
        print("fader-calibration.py: inserted calibration helpers")

    ok = patch(UTILS, INT14_OLD, INT14_NEW, "int14ToVol")
    ok &= patch(UTILS, VOL_OLD, VOL_NEW, "volToNormalized")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
