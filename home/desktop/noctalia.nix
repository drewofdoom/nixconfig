# Noctalia v5 user settings (~/.config/noctalia/). Minimal baseline.
{ ... }:

{
  programs.noctalia = {
    enable = true;
    settings = {
      # Native polkit agent: Noctalia handles pkexec / run0 / Flatpak / NM
      # prompts itself, themed to match the shell, instead of the separate
      # hyprpolkitagent window (removed in configuration.nix). Only one agent
      # may own org.freedesktop.PolicyKit1, so the two must not both run.
      # Placement knobs if you want the prompt attached to the bar rather than
      # a centered float: shell.panel.polkit_placement = "attached".
      shell.polkit_agent = true;
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Noctalia";
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "gtk3"
            "gtk4"
            "niri"
          ];
        };
      };
      wallpaper.enabled = true;
    };
  };
}
