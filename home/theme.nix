# Theming: cursor, GTK, dconf. Moved verbatim from home-common.nix.
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

  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };
}
