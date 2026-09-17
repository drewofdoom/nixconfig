# Noctalia v5 user settings (~/.config/noctalia/). Minimal baseline.
{ ... }:

{
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Noctalia";
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [ "gtk3" "gtk4" "niri" ];
        };
      };
      wallpaper.enabled = true;
    };
  };
}
