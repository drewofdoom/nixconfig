# Desktop apps (non-shell, non-wine packages). Moved verbatim from home-common.nix.
{
  pkgs,
  config,
  inputs,
  ...
}:

let
  # Plezy unstable in order to stay on latest version
  plezy = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.plezy;
in
{
  home.packages = with pkgs; [
    # Basic apps
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.pipewirecontroller.packages.${pkgs.stdenv.hostPlatform.system}.default
    libsecret

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

    # Desktop
    sone
    fragments
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

  # LADSPA plugin discovery (PipeWireController et al.): with LADSPA_PATH
  # unset, hosts fall back to /usr/lib/ladspa, which doesn't exist on NixOS —
  # so the profile's lib/ladspa (lsp-plugins, zam, x42, …) is invisible.
  # Point at the user profile + system profile explicitly. Missing dirs are
  # harmless (hosts skip them).
  home.sessionVariables = {
    LADSPA_PATH = "${config.home.profileDirectory}/lib/ladspa:/run/current-system/sw/lib/ladspa";
  };
}
