# System configuration - Umbriel + Noctalia Greeter + Flatpak
# Preserves your stock /etc/nixos settings (boot, timezone, locale, user drew).
{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.umbriel.nixosModules.default
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "ntsync" ];

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

  # Umbriel is not in stable nixpkgs; pull it from the unstable input
  programs.umbriel.package =
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.umbriel;

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

  # -- Networked multifunction (Epson, IPP Everywhere / eSCL) --
  # CUPS prints driverless over IPP; epson-escpr covers older ESC/P-R
  # models that don't. sane-airscan is the network scanner backend
  # (stock SANE is USB-only); avahi provides .local discovery.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };

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

  # Umbriel Wayland compositor (provides `umbriel` session + portal)
  programs.umbriel.enable = true;

  # Niri scrollable compositor alongside Umbriel (session selectable in greeter).
  # programs.niri.enable provides the session, portals and polkit integration.
  programs.niri.enable = true;

  # Noctalia v5 shell system-wide + recommended services
  # (NetworkManager, Bluetooth, UPower, power-profiles-daemon)
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  # Noctalia Greeter via greetd. Disable any other display manager.
  # Uses flake module: services.displayManager.noctalia-greeter
  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 24;
        path = "${pkgs.bibata-cursors}/share/icons";
      };
      keyboard = {
        layout = "us";
      };
      session.default = "Umbriel";
      user.default = "drew";
    };
  };
  services.displayManager.gdm.enable = false;
  services.displayManager.sddm.enable = false;

  # Intel Mesa graphics with 32-bit support (Wine/DXVK needs both).
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.tailscale.ipn.Native" && subject.isInGroup("tailscale")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
  security.rtkit.enable = true;

  # Pro-audio realtime privileges for the audio group (drew is a member).
  # Fixes yabridge "low memory locking limit" warning and JACK realtime errors.
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "95";
    }
    {
      domain = "@audio";
      item = "nice";
      type = "-";
      value = "-19";
    }
  ];

  # -- Auth + secrets (minimal, no full GNOME) --
  # polkit daemon + Wayland-native agent (autostarted in graphical session).
  # Noctalia v5 can also act as polkit agent; hyprpolkitagent is the fallback
  # so pkexec / Flatpak installs / NM edits always prompt.
  systemd.user.services.hyprpolkitagent = {
    description = "hyprpolkitagent - Polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Secret Service provider for Noctalia (clipboard, calendar creds).
  # libsecret alone is not enough - you need a provider.
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # GTK theming base: dconf + portal backend. Actual theme set in home-common.nix.
  programs.dconf.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.fish.enable = true;

  # System flatpak daemon (nix-flatpak's Home Manager module manages the
  # user-scope packages declared in home-common.nix).
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    corefonts
  ];

  environment.systemPackages = with pkgs; [
    neovim
    wget
    jq
    yq
    git
    bibata-cursors
    hyprpolkitagent
    gnome-keyring
    libsecret
    nautilus
    proton-pass-cli
    proton-vpn-cli
    # xwayland-satellite serves both Umbriel and Niri (Niri uses it
    # instead of plain xwayland).
    xwayland-satellite
    unar
    file-roller
  ];

  system.stateVersion = "26.05";
}
