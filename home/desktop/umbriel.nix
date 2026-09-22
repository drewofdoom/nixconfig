# Umbriel compositor settings (written to ~/.config/umbriel/config.toml)
{ ... }:

{
  imports = [
    ./umbriel/keybinds.nix
    ./umbriel/window_rule.nix
    ./umbriel/layer_rule.nix
  ];

  programs.umbriel = {
    enable = true;
    settings = {
      general = {
        autostart = [ "noctalia" ];
        mod_key = "Super";
        xwayland = true;
        show_cheatsheet = false;
      };
      include.optional.files = [
        "noctalia.toml"
        "outputs.toml"
      ];
      input = {
        window_drag_toggle = "floating";
        keyboard.layout = "us";
        touchpad = {
          tap = true;
          natural_scroll = true;
          disable_while_typing = true;
          disable_on_external_mouse = true;
          click_method = "clickfinger";
        };
        mouse = {
          accel_profile = "flat";
        };
      };
      appearance = {
        prefer_no_csd = true;
        border_width = 2;
        corner_radius = 10;
        blur = {
          enabled = true;
          optimized = true;
          passes = 2;
          radius = 1;
          noise = 0.03;
          brightness = 0.9;
          contrast = 0.9;
          saturation = 1.1;
        };
      };
      layout.scrolling = {
        center_underfull_strip = true;
        center_focused = "on_overflow";
      };
    };
  };
}
