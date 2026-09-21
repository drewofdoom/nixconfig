# User-scoped flatpaks (per-host sets can diverge in hosts/<name>/home.nix).
# Moved verbatim from home-common.nix.
{ ... }:

{
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
}
