# Noctalia v5 user settings (~/.config/noctalia/). Minimal baseline.
{ ... }:

{
  programs.noctalia = {
    enable = true;
    settings = {
      shell.polkit_agent = true;
      wallpaper.enabled = true;
    };
  };
}
