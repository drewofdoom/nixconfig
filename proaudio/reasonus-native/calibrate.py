# Injects fader-value logging into ReaSonus Native's FaderPort V2 track manager.
#
# Used by the `calibrate` build variant (see default.nix). The extension then
# appends every raw 14-bit value the device sends, plus the volume REAPER
# derives from it, to /tmp/reasonus-cal.log. That lets us measure the fader's
# real travel range and taper, which is what the volume mapping assumes spans
# 0..16383 linearly.
#
# Run from the source root: python3 calibrate.py
import pathlib
import sys

TARGET = pathlib.Path("src/csurf_faderport_v2/csurf_fp_v2_track_manager.cpp")

SIGNATURE = "void CSurf_FP_V2_TrackManager::HandleFaderMove(const int msb, const int lsb) const {"

LOGGING = """
    {
        // Append every fader value to a log file so a full sweep can be
        // captured without copying from the console. The handle is kept open
        // across calls; this runs on every MIDI event.
        static FILE *cal_fp = nullptr;
        if (!cal_fp) cal_fp = fopen("/tmp/reasonus-cal.log", "w");
        if (cal_fp) {
            const int raw = (lsb & 0x7f) | ((msb & 0x7f) << 7);
            fprintf(cal_fp, "raw=%d msb=%d lsb=%d vol=%.6f\\n",
                    raw, msb, lsb, int14ToVol(msb, lsb));
            fflush(cal_fp);
        }
    }
"""


def main() -> int:
    source = TARGET.read_text()

    if "reasonus-cal.log" in source:
        print("calibrate.py: already applied, skipping")
        return 0

    if SIGNATURE not in source:
        print(f"calibrate.py: signature not found in {TARGET}", file=sys.stderr)
        return 1

    TARGET.write_text(source.replace(SIGNATURE, SIGNATURE + LOGGING, 1))
    print(f"calibrate.py: instrumented {TARGET}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
