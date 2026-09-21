# Cursor + icon theme + window-chrome prefs. Noctalia owns GTK *color*
# theming (builtin gtk3/gtk4 templates, driven by its theme switcher -- see
# desktop/noctalia.nix), so Home Manager must NOT set gtk theme colors or
# dark-mode keys: both write the same settings.ini/dconf keys and fight.
# Icon theme is ours: Noctalia doesn't manage it (dropping it reverted
# everything to Adwaita). Conflux is packaged locally in ../../pkgs
# (not in nixpkgs yet); Papirus stays installed as fallback.
{
  pkgs,
  ...
}:

let
  conflux-icon-theme = pkgs.callPackage ../pkgs/conflux-icon-theme.nix { };
in
{
  home.packages = [ conflux-icon-theme ];

  # Bibata-Modern-Ice cursor as the default system cursor (Wayland + XWayland)
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    size = 24;
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Conflux";
      package = conflux-icon-theme;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      icon-theme = "Conflux";
    };
    # No headerbar buttons (Fedora equivalent:
    # `gsettings set org.gnome.desktop.wm.preferences button-layout ''`)
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
    };
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };
}
