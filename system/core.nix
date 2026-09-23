# Core system settings: boot, networking, nix, user, sudo.
{
  pkgs,
  ...
}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Zen 7.2.6 (matches unstable's Zen version, so the unstable 615 driver
  # below passes the kernel-version check). Revisit if Zen moves and the
  # driver doesn't follow -- fall back to pkgs.linuxPackages (6.12 LTS).
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules = [ "ntsync" ];

  # -- Kernel tuning --
  # nowatchdog: the NMI watchdog is pure overhead and a latency source; it is
  # only useful for catching hard lockups on servers. preempt=full: the kernel
  # is built PREEMPT_DYNAMIC, so this opts into full preemption at boot -- the
  # single biggest win for REAPER/JACK scheduling latency.
  boot.kernelParams = [
    "nowatchdog"
    "preempt=full"
    # Disable speculative-execution mitigations on this desktop-only machine.
    # Safe when no untrusted code runs; recovers 2-8% throughput on Zen 3.
    "mitigations=off"
  ];

  networking.networkmanager.enable = true;

  nix.settings.accept-flake-config = true;

  # Tailscale operator access for drew via group + polkit rule
  # (services.tailscale.operator doesn't exist in this NixOS version)
  users.groups.tailscale = { };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  networking.firewall.checkReversePath = "loose";

  time.timeZone = "America/Denver";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.extra-substituters = [
    "https://noctalia.cachix.org"
    "https://pipewirecontroller-nix.cachix.org"
  ];
  nix.settings.extra-trusted-public-keys = [
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    "pipewirecontroller-nix.cachix.org-1:wY/tr9Hxc0kvGW2zgh2DUjQI+LqLBCQ7bm9Wkr3dgdc="
  ];

  nixpkgs.config.allowUnfree = true;

  # nh -- flake helper that picks the config by hostname (`nh os switch`
  # builds .#shephard here, .#blackstar there). Weekly GC keeps the store lean.
  programs.nh = {
    enable = true;
    flake = "/home/drew/Projects/nixconfig";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  # Lets foreign (non-Nix) binaries execute via a compatibility loader shim.
  programs.nix-ld.enable = true;

  users.users."drew" = {
    isNormalUser = true;
    description = "Drew DeVore";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "tailscale"
      "scanner"
      "lp"
    ];
    shell = pkgs.fish;
  };

  # Trusted user: lets drew use the flake's nixConfig (extra-substituters /
  # extra-trusted-public-keys) without the "ignoring untrusted flake
  # configuration" warning. MUST be nix.settings.trusted-users -- a bare
  # top-level `trusted-users` is not a NixOS option and is silently ignored.
  nix.settings.trusted-users = [ "drew" ];

  # Persistent passwordless sudo for drew (hostname-independent,
  # survives renames unlike a hand-edit tied to `nixos`).
  security.sudo.extraRules = [
    {
      users = [ "drew" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  programs.fish.enable = true;

  system.stateVersion = "26.05";
}
