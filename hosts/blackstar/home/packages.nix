{
  pkgs,
  ...
}:

let
  # Permanent +6dB (linear gain 2.0) on the VBAN receiver node.
  # WirePlumber doesn't persist node volumes, and the vban-recv module takes
  # no gain arg, so a oneshot user service applies it after (re)start.
  # PartOf + WantedBy pipewire.service keeps it in step across restarts.
  # Applies to EVERY node named vban-receiver (one per active sender).
  vban-boost = pkgs.writeShellScriptBin "vban-boost" ''
    PATH=${
      pkgs.lib.makeBinPath [
        pkgs.pipewire
        pkgs.jq
        pkgs.coreutils
      ]
    }
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
    elektroid
    heroic
    mangohud
    protontricks

    # custom
    vban-boost
  ];

  services.flatpak.packages = [
    "hu.irl.sysex-controls"
  ];

  programs.cava.settings.general.framerate = 60;

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
}
