# blackstar-specific settings (shared system config lives in ../../system).
{
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ../../system/nvidia.nix ];

  networking.hostName = "blackstar";

  # Compressed RAM swap; no swap partition (no hibernation).
  # zstd: fast compression + decompression on Zen 3 (hardware-accelerated
  # via the kernel zstd module). 25% of 32 GiB = 8 GiB backing, which with
  # zstd's ~3:1 ratio provides ~24 GiB effective swap before any pressure.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # zram-specific VM tuning. With a compressed RAM swap device the usual
  # "avoid swapping" advice inverts: swap-in is cheap (decompress, no disk),
  # so a moderate swappiness (10) lets zram absorb infrequent cold pages
  # without being too eager. page-cluster 0 disables swap readahead --
  # readahead on zram just decompresses pages you may not need, and the
  # kernel's default of 3 is tuned for rotating disks.
  # BBR + fq: BBR is model-based (estimates bottleneck bandwidth/RTT and paces
  # to match) rather than loss-based like CUBIC, so it holds throughput and
  # keeps latency down on lossy or congested paths. `fq` is the qdisc that
  # provides the pacing BBR wants; fq_codel works but paces less smoothly.
  # Mostly matters for large transfers over a busy uplink -- this box is wired,
  # so LAN traffic sees little change. Note BBRv1 can be unfair to CUBIC flows
  # sharing a bottleneck; acceptable on a home network.
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.page-cluster" = 0;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
  };

  # Keep /boot from filling with old generations (14 entries currently).
  boot.loader.systemd-boot.configurationLimit = 10;

  # Steam needs its FHS env, udev rules (controllers) and firewall ports --
  # the package alone won't work.
  # extraCompatPackages (-> STEAM_EXTRA_COMPAT_TOOLS_PATHS) is the *only*
  # supported way to get Proton-GE on NixOS. proton-ge-bin deliberately ships
  # a junk `out` output telling you not to add it to an environment; the real
  # tool is its `steamcompattool` output, which the steam module points Steam
  # at via makeSearchPathOutput. Steam then finds the tool through the
  # compatibilitytool.vdf in that output. Do NOT install it into
  # environment.systemPackages / home.packages -- that would only put the
  # breadcrumb text on PATH, not a working tool.
  # ProtonPlus drops its downloads into ~/.local/share/Steam/compatibilitytools.d,
  # which Steam reads too but is unmanaged and can go stale (it is currently
  # empty), so declarative is both more reliable and reproducible.
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    # Gamescope session disabled: the monitor's HDR is poor, and the session
    # auto-enables HDR (via ENABLE_GAMESCOPE_WSI/DXVK_HDR defaults) causing
    # corruption on toggle. Use `gamescope -W 3840 -H 1080 -r 60 -- %command%`
    # as a per-game launch option in Steam instead, which scales 3840x1080 up
    # to the panel's native 5120x1440 without touching HDR or leaving Umbriel.
    gamescopeSession = {
      enable = false;
    };
  };
  programs.gamescope = {
    enable = true;
    # capSysNice = true; # BROKEN https://github.com/NixOS/nixpkgs/issues/351516
  };
  programs.gamemode.enable = true;

  # GameMode config (generates /etc/gamemode.ini).
  # desiredgov=performance is the point of GameMode here: it raises the CPU
  # governor only while a game is running, then restores whatever was active.
  # defaultgov is deliberately left unset so exit restores the *current* state
  # rather than forcing one -- that keeps the Noctalia power toggle (which
  # drives power-profiles-daemon) authoritative when no game is running.
  # softrealtime=off: SCHED_ISO is not in upstream kernels, so it is a no-op.
  # disable_splitlock=1 drops the split-lock mitigation during games (it is a
  # measurable cost on this 5800X and the risk is irrelevant for a desktop).
  programs.gamemode.settings = {
    general = {
      desiredgov = "performance";
      softrealtime = "off";
      renice = 0;
      ioprio = 0;
      inhibit_screensaver = 1;
      disable_splitlock = 1;
    };
  };

  # LACT GPU control (RTX 3080) - daemon + UI. The daemon does the
  # actual clocks/fan/power work; enable it, not just the package.
  services.lact.enable = true;

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
    # Stable's tdarr-node (2.74.01) can't build: its ccextractor dep
    # (0.94-unstable-2025-05-20) fails with "stray '#'" errors under gcc 15.
    # Unstable's node (2.86.01, ccextractor 0.96.6) has the fix. Imported
    # with allowUnfree since the raw flake input doesn't inherit
    # nixpkgs.config.allowUnfree (tdarr-node is unfree).
    package =
      (import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      }).tdarr-node;
    serverURL = "http://tdarr.bunny-octatonic.ts.net:8266";
    type = "mapped";
    startPaused = false;
    workers.transcodeGPU = 1;
    workers.transcodeCPU = 0;
    workers.healthcheckGPU = 0;
    workers.healthcheckCPU = 0;
  };

  # Pin tdarr to uid/gid 911 to match the server container's PUID/PGID=911,
  # so files created through the CIFS mount share ownership with the server.
  users.users.tdarr.uid = 911;
  users.groups.tdarr.gid = 911;

  # Tdarr_Node 2.86 uses serverURL only for the initial engine check; all
  # ongoing API calls go to serverIP:serverPort (default 0.0.0.0:8266 --
  # the ECONNREFUSED in the logs). The module sets no serverIP, so override
  # it here. Hostname, not the raw tailnet IP: :8266 is only reachable
  # through the Tailscale Serve frontend (tdarr.bunny-octatonic.ts.net),
  # direct-to-IP on 8266 is refused.
  systemd.services.tdarr-node-blackstar.environment = {
    serverIP = "tdarr.bunny-octatonic.ts.net";
    serverPort = "8266";
  };

  # The node stages transcodes under /temp (mirrors the compose `tdarr_cache:/temp`
  # volume). The unit's strict sandbox can't write there by default, so create
  # it and whitelist it.
  systemd.tmpfiles.rules = [
    "d /temp 0750 tdarr tdarr -"
    # Audio subvolumes are root-owned; hand them to drew (audio work runs as
    # the desktop user). tmpfiles runs at boot and adopts the mountpoints each
    # time, so ownership survives even if a subvol is recreated.
    "d /home/drew/Audio 0755 drew users -"
    "d /home/drew/Audio/Archive 0755 drew users -"
    "d /home/drew/Audio/Assets 0755 drew users -"
    "d /home/drew/Audio/Workspace 0755 drew users -"
  ];
  systemd.services.tdarr-node-blackstar.serviceConfig.ReadWritePaths = [ "/temp" ];

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

  # -- Dedicated audio volume (nvme1n1p3, 731 GiB, label "audio") --
  # Created by shrinking the old 930 GiB root partition: p2 is now ~198 GiB
  # and p3 fills the remainder. Three subvolumes on ONE btrfs filesystem (so
  # they share the same UUID; the `subvol=` option picks which one mounts).
  # Mounted under ~/Audio rather than /audio so audio work lives in the home
  # tree; systemd orders these After=home.mount automatically.
  #
  # `archive` + `assets` keep CoW + checksums: both are effectively
  # write-once and want to be snapshottable (`btrfs send` for backup, and
  # checksums to catch bit-rot on long-lived archives/sample libraries).
  # Compression stays OFF everywhere: archive is FLAC and assets are already
  # compressed or incompressible, so zstd would burn CPU for ~nothing.
  # `workspace` is scratch/production -- nodatacow/nodatasum avoid
  # fragmentation + write amplification on large takes, at the cost of not
  # being snapshottable (nodatacow snapshots are not coherent). Never snapshot
  # workspace.
  # No `nofail`: p3 shares a disk with `/`, so a mount failure means something
  # is seriously wrong and boot should stop rather than hide it.
  #
  # `x-gvfs-hide` keeps these out of the Nautilus/GVFS sidebar. They _are_
  # ordinary fstab mounts already, but gvfs's udisks2 volume monitor shows
  # everything mounted under $HOME (gvfsudisks2volumemonitor.c
  # should_show_volume(): the home-dir check returns TRUE), complete with
  # eject buttons and drive badges. `x-gvfs-hide` is parsed by gvfs straight
  # out of the fstab options and trumps that check; the kernel and systemd
  # ignore unknown `x-` options, so it is inert everywhere else. (To force one
  # _into_ the sidebar elsewhere, `x-gvfs-show`; `x-gvfs-name=` renames it.)
  fileSystems."/home/drew/Audio/Archive" = {
    device = "/dev/disk/by-uuid/a58a58dc-7d07-4904-beaa-52ea4ba2a248";
    fsType = "btrfs";
    options = [
      "subvol=/archive"
      "noatime"
      "x-gvfs-hide"
    ];
  };
  fileSystems."/home/drew/Audio/Assets" = {
    device = "/dev/disk/by-uuid/a58a58dc-7d07-4904-beaa-52ea4ba2a248";
    fsType = "btrfs";
    options = [
      "subvol=/assets"
      "noatime"
      "x-gvfs-hide"
    ];
  };
  fileSystems."/home/drew/Audio/Workspace" = {
    device = "/dev/disk/by-uuid/a58a58dc-7d07-4904-beaa-52ea4ba2a248";
    fsType = "btrfs";
    options = [
      "subvol=/workspace"
      "noatime"
      "nodatacow"
      "nodatasum"
      "x-gvfs-hide"
    ];
  };

  # noatime on the root/home btrfs filesystems: purely a metadata-write
  # reduction, safe and needs no data rewrite. Deliberately NOT adding
  # compression here -- /home is 565 GiB and ~535 GiB of that is the Steam
  # library (already-compressed game archives), so whole-fs compression would
  # cost CPU on every game write for near-zero saving. Plain assignment (not
  # mkForce): the generated hardware-configuration.nix sets no options for
  # these, and list options merge additively -- mkForce would clobber NixOS's
  # own `x-initrd.mount` on `/`, which root needs to mount in the initrd.
  fileSystems."/".options = [ "noatime" ];
  fileSystems."/home".options = [ "noatime" ];

  # zstd:1 on /nix ONLY. The store is hundreds of thousands of small files
  # (dlopen/exec), and this disk is a DRAM-less SN550 that is weak at random
  # small reads, so fewer bytes per file is a modest win. zstd:1 is ~1.4 GB/s
  # on this 5800X -- cheap enough to be near-neutral on bulk reads and worth
  # it on small-file reads. NOT on `/` (trivial content) and NOT on `/home`
  # (535 GiB of already-compressed Steam archives). Affects newly written
  # paths only; existing store paths stay uncompressed until replaced.
  # Plain assignment so the subvol/x-initrd.mount flags merge additively.
  fileSystems."/nix".options = [ "compress=zstd:1" ];
}
