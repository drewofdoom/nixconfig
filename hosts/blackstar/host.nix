# blackstar-specific settings.
# NOTE: not wired into flake.nix yet -- drop in the hardware-configuration.nix
# generated on that machine (nixos-generate-config), then add
#   blackstar = mkHost "blackstar";
# to nixosConfigurations.
{ pkgs, ... }:

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

  # -- Tdarr node (Blackstar only, mapped) --
  # Server lives on rosie (compose: internal node `rosie`, serverPort 8266,
  # auth disabled, so no API key needed). This node gets 1 NVENC GPU worker;
  # server disk speed is the bottleneck, so no more.
  # Mapped = node reads/writes the library directly via /mnt/data/media below,
  # which mirrors the server's paths, so no pathTranslators needed.
  # Node polls the server outbound -- no inbound firewall ports needed.
  services.tdarr.nodes.blackstar = {
    name = "blackstar";
    serverURL = "http://192.168.0.27:8266";
    type = "mapped";
    workers.transcodeGPU = 1;
    workers.transcodeCPU = 0;
  };

  # Pin tdarr to uid/gid 911 to match the server container's PUID/PGID=911,
  # so files created through the CIFS mount share ownership with the server.
  users.users.tdarr.uid = 911;
  users.groups.tdarr.gid = 911;

  # -- CIFS mount for the server's media share --
  # Credentials live OUTSIDE the repo at /etc/samba/media.credentials (root,
  # mode 0600) -- create it with:
  #   sudo mkdir -p /etc/samba
  #   printf 'username=\npassword=\n' | sudo tee /etc/samba/media.credentials
  #   sudo chmod 0600 /etc/samba/media.credentials
  # then fill in the values. The SMB user needs read+write on the share --
  # a mapped node writes transcoded files back to the library.
  # automount = the share is only connected on first access, and
  # idle-timeout disconnects it after 60s idle. nofail so a missing
  # file/share never blocks boot.
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/data/media" = {
    device = "//192.168.0.27/media";
    fsType = "cifs";
    options = [
      "credentials=/etc/samba/media.credentials"
      "uid=911,gid=911"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "nofail"
      "rw"
    ];
  };
}
