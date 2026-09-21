# Shared Home Manager config for drew - terminal, browser, dev tools, theming.
# Compositor settings live in umbriel.nix / niri.nix / noctalia.nix.
{
  pkgs,
  inputs,
  lib,
  ...
}:

let
  # Recent yabridge dev build (actions run 30739764611, commit b580a9f).
  yabridge-dev = pkgs.yabridge.overrideAttrs (oldAttrs: {
    version = "5.1.1-57-gb580a9f";
    src = pkgs.fetchFromGitHub {
      owner = "robbert-vdh";
      repo = "yabridge";
      rev = "b580a9f7fc46509767ca156d4f92872552b9e571";
      hash = "sha256-TiKiyE3GZYCX1+vooHdD03fAhNQPAA1IzTfkG++I7TY=";
    };
    # nixpkgs' 32-bit/removal patches don't apply to this dev commit, but the
    # NIX_PROFILES lookup patch does (verified) and is required on NixOS so the
    # chainloader finds libyabridge-vst{2,3}.so from the user profile.
    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/NixOS/nixpkgs/raw/b1b875982b17dabde9b4a37f3e229e74913e6db3/pkgs/by-name/ya/yabridge/libyabridge-from-nix-profiles.patch";
        hash = "sha256-Ial9AkHvOfd1zR2uFBNPEKwpv/qgYxycZufEn9dXHl0=";
      })
    ];
  });
  yabridgectl-dev = pkgs.yabridgectl.overrideAttrs (oldAttrs: {
    version = "5.1.1-57-gb580a9f";
    src = pkgs.fetchFromGitHub {
      owner = "robbert-vdh";
      repo = "yabridge";
      rev = "b580a9f7fc46509767ca156d4f92872552b9e571";
      hash = "sha256-TiKiyE3GZYCX1+vooHdD03fAhNQPAA1IzTfkG++I7TY=";
    };
  });

  # Plezy unstable in order to stay on latest version
  plezy = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.plezy;
in
{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.umbriel.homeModules.default
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./umbriel.nix
    ./noctalia.nix
    ./proaudio
  ];

  home.username = "drew";
  home.homeDirectory = "/home/drew";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  # Bibata-Modern-Ice cursor as the default system cursor (Wayland + XWayland)
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    size = 24;
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  # GTK 3/4 as default theming engine. dconf forces dark preference so
  # Flatpak + GTK + libadwaita apps follow Noctalia dark mode.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Papirus-Dark";
    };
    # No headerbar buttons (Fedora equivalent:
    # `gsettings set org.gnome.desktop.wm.preferences button-layout ''`)
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Noto Sans";
      size = 11;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk3.extraConfig.gtk-decoration-layout = ":";
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-decoration-layout = ":";
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Drew DeVore";
      email = "drew@devorcula.com";
    };
    settings.init.defaultBranch = "main";
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      fish_add_path --global --prepend "$HOME/.local/bin"
    '';
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      alias cat='bat --plain'
      alias ls='eza --color=always'
      alias ll='eza --long --icons=always'
      alias la='eza -a'
      alias laa='eza -a --long --icons=always'
      alias lx='eza --long --icons=always --hyperlink=auto'
      alias grep='ugrep'
      alias egrep='ugrep -E'
      alias fgrep='ugrep -F'
      alias rgrep='ugrep -R'
      alias t='bat --style=plain --paging=never'
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
  };

  programs.atuin = {
    enable = true;
    # 18.21 wrote history "v2" records to the sync server; stable 18.15.2
    # can't read them (unknown history version "v2"). Stay on unstable.
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.atuin;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
      enter_accept = true;
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Maple Mono NF";
      font-size = 11;
      theme = "noctalia";
    };
  };

  programs.yazi = {
    enable = true;
  };

  # Zed (native, not FHS) + declarative extensions and toolchains.
  # Merges into ~/.config/zed/settings.json, your in-app edits are preserved.
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
    ];
    extraPackages = with pkgs; [
      nil
      nixd
      nixfmt
      ripgrep
      nodejs
      python3
    ];
    userSettings = {
      languages.Nix = {
        language_servers = [ "nil" ];
        formatter = {
          external = {
            command = "nixfmt";
            arguments = [ ];
          };
        };
      };
    };
  };

  # Auto-activate flake devShells on directory entry.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    # Basic apps
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.pipewirecontroller.packages.${pkgs.stdenv.hostPlatform.system}.default
    libsecret
    wineWow64Packages.stagingFull
    winetricks
    dxvk
    dxvk.out

    # Chat apps
    telegram-desktop
    equibop
    fractal
    slack

    # GUI stuff
    wl-clipboard
    wlr-randr
    adw-gtk3
    gnome-themes-extra
    papirus-icon-theme

    # CLI tools
    # NOTE: no nixpkgs opencode -- unstable (1.18.30) crashes resolving
    # any model (TypeError err_* on every prompt). Stable (1.15.10) exists
    # in nixpkgs but is older than upstream. Upstream binary installed via
    # https://opencode.ai/install to ~/.opencode/bin (1.18.31+, autoupdates).
    # See home.sessionPath below.
    gh
    git
    nil
    nixd
    eza
    ugrep
    bat
    ripgrep
    fd
    ffmpeg # ffmpeg/ffprobe/ffplay on PATH
    glib.bin # gio (GIO metadata, e.g. Nautilus custom folder attributes)
    python3
    uv
    nodejs
    btop
    gping

    # Desktop
    sone
    fragments
    rustdesk-flutter
    showtime
    plezy
    mpv
    decibels
    papers
    loupe
    resources
    simple-scan
    proton-vpn
    openmeters

    # Yabridge (Nix-built, no ~/.local/bin binaries). Stays here rather than
    # ./proaudio: it's bridge infrastructure, and the dev override lives in
    # the let block above.
    yabridge-dev
    yabridgectl-dev
  ];

  # home-common.nix, alongside wineWow64Packages.stagingFull + winetricks
  home.file.".local/bin/wine64".source = "${pkgs.wineWow64Packages.stagingFull}/bin/wine";

  xdg.enable = true;

  # Standard XDG user dirs (Documents, Downloads, Music, ...), created if missing.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Flatpaks, user-scoped (per-host sets can diverge in hosts/<name>/home.nix).
  services.flatpak = {
    enable = true;
    packages = [
      "com.github.tchx84.Flatseal"
      "org.gtk.Gtk3theme.adw-gtk3-dark"
      "io.github.maniacx.BudsLink"
    ];
    overrides.global.Context.filesystems = [
      "xdg-config/gtk-3.0:ro"
      "xdg-config/gtk-4.0:ro"
    ];
  };

  # (REAPER + extensions are configured declaratively in ./proaudio.)

  # -- SSH agent via proton-pass-cli --
  # Uses proton-pass as a drop-in ssh-agent, storing keys in Proton Pass.
  # Secret backend uses dbus (gnome-keyring), which is already enabled in configuration.nix.
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";
    PROTON_PASS_LINUX_KEYRING = "dbus";
    PAGER = "bat";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  # Upstream opencode binary (see CLI tools note above).
  home.sessionPath = [
    "$HOME/.opencode/bin"
    "$HOME/.local/bin"
  ];

  # Papirus "projects" folder icon on ~/Projects (GIO metadata lives in the
  # binary gvfs-metadata store, so this re-applies it idempotently each switch
  # instead of a config file). Guarded: a missing session bus never fails activation.
  home.activation.projectsFolderIcon = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    GIO="${pkgs.glib.bin}/bin/gio"
    dir="$HOME/Projects"
    if [ -d "$dir" ]; then
      curIcon=$("$GIO" info -a metadata::custom-icon-name "$dir" 2>/dev/null | sed -n 's/^  metadata::custom-icon-name: //p')
      if [ "$curIcon" != "folder-projects" ]; then
        "$GIO" set -t string "$dir" metadata::custom-icon-name folder-projects 2>/dev/null || true
      fi
    fi
  '';

  systemd.user.services.proton-pass-ssh-agent = {
    Unit = {
      Description = "Proton Pass SSH Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent start --socket-path %h/.ssh/proton-pass-agent.sock";
      Environment = "PROTON_PASS_LINUX_KEYRING=dbus";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
