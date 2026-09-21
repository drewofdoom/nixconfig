# Cursor + window-chrome prefs. Noctalia owns all color/icon/font theming
# (builtin gtk3/gtk4 templates, driven by its theme switcher -- see
# desktop/noctalia.nix), so Home Manager must NOT set gtk.* themes or
# org/gnome/desktop/interface: both write the same settings.ini/dconf keys
# and fight. What stays here is what Noctalia doesn't manage:
# the Bibata cursor and the empty headerbar button layout.
{ pkgs, ... }:

{
  # Bibata-Modern-Ice cursor as the default system cursor (Wayland + XWayland)
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    size = 24;
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  dconf.settings = {
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
