# Screen recording: wf-recorder (wlroots-screencopy) + slurp for the
# interactive region picker, wrapped in the `screen-record` toggle script
# (start with no args = region, --full = whole output, re-run to stop).
# Keybinds: umbriel/keybinds.nix. Requires Umbriel to implement
# wlr-screencopy-v1 and xdg-output.
{ pkgs, ... }:

let
  screenRecord = pkgs.runCommand "screen-record-sh" { } ''
    install -Dm755 ${./screen-record.sh} $out/bin/screen-record
  '';
in
{
  home.packages = [
    screenRecord
    pkgs.libnotify # notify-send, for start/stop feedback
    pkgs.slurp
    pkgs.wf-recorder
  ];
}
