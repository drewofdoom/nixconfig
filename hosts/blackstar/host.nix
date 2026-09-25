# blackstar-specific settings (shared system config lives in ../../system).
{ ... }:

{
  imports = [
    ../../system/nvidia.nix
    ./host/gaming.nix
    ./host/tdarr.nix
    ./host/pipewire.nix
  ];

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

  # LACT GPU control (RTX 3080) - daemon + UI. The daemon does the
  # actual clocks/fan/power work; enable it, not just the package.
  services.lact.enable = true;

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
