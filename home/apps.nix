# Desktop apps (non-shell, non-wine packages). Moved verbatim from home-common.nix.
{
  pkgs,
  inputs,
  ...
}:

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
    adw-gtk3
    gnome-themes-extra
    papirus-icon-theme

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
    openmeters
  ];
}
