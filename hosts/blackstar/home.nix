# blackstar-only home config.

{ pkgs, ... }:

let
  # Permanent +6dB (linear gain 2.0) on the VBAN receiver node.
  # WirePlumber doesn't persist node volumes, and the vban-recv module takes
  # no gain arg, so a oneshot user service applies it after (re)start.
  # PartOf + WantedBy pipewire.service keeps it in step across restarts.
  # Applies to EVERY node named vban-receiver (one per active sender).
  vban-boost = pkgs.writeShellScriptBin "vban-boost" ''
    PATH=${pkgs.lib.makeBinPath [ pkgs.pipewire pkgs.jq pkgs.coreutils ]}
    for i in $(seq 1 30); do
      IDS=$(pw-dump 2>/dev/null | jq -r '.[] | select(.type == "PipeWire:Interface:Node" and .info.props."node.name" == "vban-receiver") | .id')
      if [ -n "$IDS" ]; then
        for ID in $IDS; do
          pw-cli set-param "$ID" Props '{channelVolumes: [ 2.0 2.0 ] }' >/dev/null
        done
        exit 0
      fi
      sleep 1
    done
    echo "vban-boost: vban-receiver node never appeared" >&2
    exit 1
  '';
in

{
  home.packages = with pkgs; [
    heroic
    protontricks
    mangohud
    elektroid

    # keep uv available for ad-hoc pip work
    uv

    vban-boost
  ];

  systemd.user.services.vban-boost = {
    Unit = {
      Description = "Apply +6dB gain to vban-receiver nodes";
      After = [ "pipewire.service" ];
      PartOf = [ "pipewire.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${vban-boost}/bin/vban-boost";
    };
    Install.WantedBy = [ "pipewire.service" ];
  };

  services.flatpak.packages = [
    "hu.irl.sysex-controls"
  ];

  programs.umbriel.settings = {
    # VRR is set per-output — there is no top-level vrr option.
    # DP-1 gets VRR (gaming on the ultrawide); HDMI-A-1 does not (secondary monitor).

    output = {
      "DP-1" = {
        mode = "5120x1440@75";
        position = [
          0
          0
        ];
        hdr = "auto";
        sdr_white = 400;
        vrr = "always";
      };
      "HDMI-A-1" = {
        mode = "1920x1080@60";
        position = [
          3150
          1440
        ];
        hdr = "auto";
        sdr_white = 400;
        vrr = "disabled";
      };
    };

    window_rule = [
      {
        match.title = "^notificationtoasts_.+_desktop";
        default_floating = true;
        default_position = {
          x = 10;
          y = 10;
          anchor = "bottom_right";
        };
        default_focused = false;
        default_pinned = true;
      }
    ];
  };
}
