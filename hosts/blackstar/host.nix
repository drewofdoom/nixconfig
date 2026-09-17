# blackstar-specific settings.
# NOTE: not wired into flake.nix yet -- drop in the hardware-configuration.nix
# generated on that machine (nixos-generate-config), then add
#   blackstar = mkHost "blackstar";
# to nixosConfigurations.
{ ... }:

{
  imports = [ ../../modules/nvidia.nix ];

  networking.hostName = "blackstar";

  # Compressed RAM swap; no swap partition (no hibernation).
  zramSwap.enable = true;

  # Steam needs its FHS env, udev rules (controllers) and firewall ports --
  # the package alone won't work.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.gamemode.enable = true;

  # LACT GPU control (RTX 3080) - daemon + UI. The daemon does the
  # actual clocks/fan/power work; enable it, not just the package.
  services.lact.enable = true;

  # -- Pro-audio PipeWire tuning (Blackstar only) --
  # Low-latency base (ported from Fedora 10-low-latency.conf):
  # 48kHz, 128-quantum (~2.7ms), max 2 buffers per link, rtkit priorities.
  # NOTE: PipeWireController (99-pipewire-controller.conf, quantum 256) overrides
  # the quantum at runtime when you use the app -- that is expected, the base
  # here is what applies before/without the app.
  services.pipewire.extraConfig.pipewire."10-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.allowed-rates" = [
        44100
        48000
        88200
        96000
        176400
        192000
      ];
      "default.clock.quantum" = 128;
      "default.clock.min-quantum" = 64;
      "default.clock.max-quantum" = 8192;
      "link.max-buffers" = 2;
    };
    "context.modules" = [
      {
        name = "libpipewire-module-rtkit";
        args = {
          "nice.level" = -11;
          "rt.prio" = 95;
          "rt.time.soft" = 200000;
          "rt.time.hard" = 200000;
        };
        flags = [
          "ifexists"
          "nofail"
        ];
      }
    ];
  };

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
