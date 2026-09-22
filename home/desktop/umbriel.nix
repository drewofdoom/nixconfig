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
      # Native Wayland Wine/Proton. Verified working on this box: games run
      # through winewayland.so and set the `proton-game` tag plus
      # content_type=game, which is what the VRR rules below key off. Without
      # this they go through winex11.so -> xwayland-satellite instead.
      # Umbriel captures [environment] at startup only -- restart Umbriel and
      # fully quit/relaunch Steam for a change to take effect, and run
      # `systemctl --user unset-environment PROTON_ENABLE_WAYLAND` if removed.
      environment.PROTON_ENABLE_WAYLAND = "1";
      include.files = [ "noctalia.toml" ];
      input = {
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
