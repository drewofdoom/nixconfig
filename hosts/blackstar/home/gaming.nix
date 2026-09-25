# blackstar-only gaming user packages (STALKER GAMMA install tooling).
# System-level gaming (steam, gamescope, gamemode) lives in ../host/gaming.nix.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # GAMMA install engine deps (Mord3rca/gamma-launcher or Fleorens wrapper).
    # umu-launcher provides `umu-run` (Proton runtime, no Steam needed).
    umu-launcher
    p7zip # `7z` extraction of Anomaly / GAMMA archives
    unrar # ships lib/libunrar.so; see UNRAR_LIB_PATH below
    python3 # venv for gamma-launcher / stalker-gamma-linux
    pipx # optional: isolated install of gamma-launcher

    # GTK4/libadwaita GUI deps for stalker-gamma-linux-gui
    # (PyGObject has no pip wheel; must come from the distro).
    gtk4
    libadwaita
    gobject-introspection
    python3Packages.pygobject3
  ];

  # The PyPI `unrar` module (used by gamma-launcher) loads libunrar.so via
  # ctypes and only looks in system paths + $UNRAR_LIB_PATH. On NixOS the lib
  # lives in the nix store, so point it there explicitly.
  home.sessionVariables = {
    UNRAR_LIB_PATH = "${pkgs.unrar}/lib/libunrar.so";
  };
}
