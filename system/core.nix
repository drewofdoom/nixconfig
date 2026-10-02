# Core system settings: boot, networking, nix, user, sudo.
{
  pkgs,
  config,
  ...
}:

{
  nix = {
    settings = {
      accept-flake-config = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [
        "https://noctalia.cachix.org"
        "https://pipewirecontroller-nix.cachix.org"
      ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "pipewirecontroller-nix.cachix.org-1:wY/tr9Hxc0kvGW2zgh2DUjQI+LqLBCQ7bm9Wkr3dgdc="
      ];
      trusted-users = [ "drew" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      systemd = {
        enable = true;
        network.wait-online.enable = false;
      };
    };

    kernelPackages = pkgs.linuxPackages;
    kernelModules = [ "ntsync" ];
    kernelParams = [
      "nowatchdog"
      "preempt=full"
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=auto"
      # Disable speculative-execution mitigations on this desktop-only machine.
      "mitigations=off"
    ];

    plymouth.enable = true;
  };

  systemd = {
    network.wait-online.enable = false;
    services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];
  };

  networking = {
    networkmanager.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      checkReversePath = "loose";
    };
  };

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

  services = {
    tailscale = {
      enable = true;
    };

    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "drew" ];
        MaxAuthTries = 3;
        PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
      };
    };
  };

  programs = {
    nh = {
      enable = true;
      flake = "/home/drew/Projects/nixconfig";
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 5";
      };
    };

    # Lets foreign (non-Nix) binaries execute via a compatibility loader shim.
    nix-ld.enable = true;

    fish.enable = true;
  };

  users = {
    users = {
      "drew" = {
        isNormalUser = true;
        description = "Drew DeVore";
        # Keep the systemd user manager alive after logout, otherwise user
        # services (Hermes gateway, home-manager, …) stop at last session end.
        linger = true;
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
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIstrtZnIuDhLiAhUk5y5fa2eJ4J28g2vunTEo9Gmvad drew@devorcula.com"
        ];
      };
    };
    groups.tailscale = { };
  };

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

  system.stateVersion = "26.05";
}
