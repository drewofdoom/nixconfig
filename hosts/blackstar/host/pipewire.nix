{ ... }:

{
  # VBAN receiver (ported from Fedora 20-vban-recv.conf). Listens on enp7s0,
  # creates a `vban-receiver` Audio/Source stream per incoming session.
  services.pipewire.extraConfig.pipewire."20-vban-recv" = {
    "context.modules" = [
      {
        name = "libpipewire-module-vban-recv";
        args = {
          "local.ifname" = "enp7s0";
          "sess.latency.msec" = 12;
          # false lets the node suspend when idle instead of always DSP-running.
          # The receiver node itself is always listed; per-stream nodes only
          # appear while a sender is actually streaming (via stream.rules).
          "node.always-process" = false;
          "node.driver" = false;
          "audio.position" = [
            "FL"
            "FR"
          ];
          "resample.quality" = 0;
          "resample.disable" = false;
          "stream.props" = {
            "media.class" = "Audio/Source";
            "node.name" = "vban-receiver";
            "priority.session" = 100;
            "audio.format" = "S24_3LE";
          };
          "stream.rules" = [
            {
              matches = [ { "sess.name" = "~.*"; } ];
              actions = {
                create-stream = {
                  "stream.props" = {
                    "audio.position" = [
                      "FL"
                      "FR"
                    ];
                    "media.class" = "Audio/Source";
                    "node.name" = "vban-receiver";
                    "priority.session" = 100;
                    "audio.format" = "S24_3LE";
                  };
                };
              };
            }
          ];
        };
      }
    ];
  };

  # VBAN uses UDP 6980 by default -- yes, you must open it manually.
  networking.firewall.allowedUDPPorts = [ 6980 ];
}
