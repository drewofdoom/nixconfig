# Desktop apps (non-shell, non-wine packages). Moved verbatim from home-common.nix.
{
  pkgs,
  config,
  inputs,
  ...
}:

let
  # Unstable overrides
  plezy = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.plezy;
in
{
  home.packages = with pkgs; [
    # Basic apps
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.pipewirecontroller.packages.${pkgs.stdenv.hostPlatform.system}.default
    file-roller
    nautilus
    nautilus-open-any-terminal
    sushi

    # Chat apps
    telegram-desktop
    equibop
    fractal
    slack

    # GUI stuff
    wl-clipboard
    wlr-randr
    # Theme packages kept as fallback (Noctalia templates own active theming;
    # see theme.nix). The Flatpak adw-gtk3-dark theme is a separate flatpak.
    # adwaita-icon-theme is Conflux's Inherits fallback chain.
    adwaita-icon-theme
    adw-gtk3
    gnome-themes-extra
    papirus-icon-theme

    # Audio / media tools
    flac
    mediainfo
    sox
    pv

    # Archive / system utilities
    unzip
    zip
    lsof
    yt-dlp

    # Desktop
    sone
    transmission_4-gtk
    rustdesk-flutter
    showtime
    mpv
    decibels
    papers
    loupe
    resources
    simple-scan
    proton-vpn
    proton-pass
    openmeters
    plezy
  ];

  # Zed from nixpkgs-unstable rather than the system channel (26.05 still
  # carries 1.3.6; unstable is 1.22.x). Declarative extensions and toolchains;
  # merges into ~/.config/zed/settings.json, in-app edits are preserved.
  #
  # Native, not zed-editor-fhs: the FHS wrapper is only needed for extensions
  # that hardcode /usr/bin/... paths (the "without nix-specific modifications"
  # case). The extensions used here (nix, toml) are nix-aware, so they resolve
  # tools via the nix-provided language server/toolchain paths instead.
  # Trade-off: FHS makes arbitrary community extensions work, at the cost of a
  # ~large wrapper and a /nix/store-visible FHS layer; flip to
  # `inputs.nixpkgs-unstable...zed-editor-fhs` if a specific extension
  # misbehaves.
  programs.zed-editor = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zed-editor;
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

  # LADSPA/LV2 plugin discovery (PipeWireController et al.): with these
  # unset, hosts fall back to /usr/lib/{ladspa,lv2}, which doesn't exist on
  # NixOS — so the profile's lib/{ladspa,lv2} (lsp-plugins, zam, x42, …) is
  # invisible. Point at the user profile + system profile explicitly.
  # Missing dirs are harmless (hosts skip them).
  home.sessionVariables = {
    LADSPA_PATH = "${config.home.profileDirectory}/lib/ladspa:/run/current-system/sw/lib/ladspa";
    LV2_PATH = "${config.home.profileDirectory}/lib/lv2:/run/current-system/sw/lib/lv2";
  };

  # PipeWireController spawns each filter chain / virtual node as
  # `pwctl-chain@<id>` running `/usr/bin/pipewire -c` — a hardcoded FHS path
  # that doesn't exist on NixOS (units die 203/EXEC in a restart loop).
  # Drop-in override re-points ExecStart at the stable system profile path.
  # (Kept as a drop-in, not an edit: the app manages the base unit file.)
  home.file.".config/systemd/user/pwctl-chain@.service.d/override.conf".text = ''
    [Service]
    ExecStart=
    ExecStart=/run/current-system/sw/bin/pipewire -c %i.conf
  '';
}
