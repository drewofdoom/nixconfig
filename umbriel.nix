# Umbriel compositor settings (written to ~/.config/umbriel/config.toml)
{ ... }:

{
  programs.umbriel = {
    enable = true;
    settings = {
      general = {
        autostart = [ "noctalia" ];
        mod_key = "Super";
        xwayland = true;
        show_cheatsheet = false;
      };
      include.files = [ "noctalia.toml" ];
      input.keyboard.layout = "us";
      input.touchpad = {
        tap = true;
        natural_scroll = true;
        disable_while_typing = true;
        disable_on_external_mouse = true;
        click_method = "clickfinger";
      };
      appearance = {
        prefer_no_csd = true;
        border_width = 2;
        corner_radius = 10;
      };
      appearance.blur = {
        enabled = true;
        optimized = true;
        passes = 3;
        radius = 3;
        noise = 0.02;
        brightness = 0.9;
        contrast = 0.9;
        saturation = 1.1;
      };
      layout.scrolling = {
        center_underfull_strip = true;
        center_focused = "on_overflow";
      };
      window_rule = [
        {
          blur = true;
          blur_optimized = false;
        }
        {
          match.app_id = "^dev.noctalia.Noctalia$";
          default_floating = true;
        }
      ];
      layer_rule = [
        {
          match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$";
          blur = true;
          blur_ignore_alpha = 0.5;
          blur_optimized = false;
        }
      ];
      keybinds = {
        # === Application Launchers ===
        "Mod+Return" = "spawn:ghostty";
        "Mod+Space" = "spawn:noctalia msg panel-toggle launcher";
        "Mod+B" = "spawn:zen";
        "Mod+E" = "spawn:nautilus";

        # === Actions ===
        "Mod+D" = { action = "overview-toggle"; repeat = false; };
        "Mod+Q" = { action = "window-close"; repeat = false; };
        "Mod+F" = { action = "window-toggle-maximize"; repeat = false; };
        "Mod+Shift+F" = { action = "window-toggle-fullscreen"; repeat = false; };
        "Mod+T" = { action = "window-toggle-floating"; repeat = false; };
        "Mod+grave" = { action = "scratchpad-toggle"; repeat = false; };

        # === Focus (window directional + mouse) ===
        "Mod+Up" = "window-focus-up";
        "Mod+Ctrl+Up" = "window-move-up";
        "Mod+Down" = "window-focus-down";
        "Mod+Ctrl+Down" = "window-move-down";
        "Mod+Left" = "window-focus-left";
        "Mod+Ctrl+Left" = "column-move-left";
        "Mod+Right" = "window-focus-right";
        "Mod+Ctrl+Right" = "column-move-right";
        "Mod+MouseBack" = "window-focus-left";
        "Mod+MouseForward" = "window-focus-right";
        "Mod+comma" = "window-consume-or-expel-left";
        "Mod+period" = "window-consume-or-expel-right";
        "Mod+Ctrl+grave" = "window-toggle-scratchpad";

        # === Workspace navigation (umbriel cycles workspaces) ===
        "Mod+Page_Up" = { action = "workspace-previous"; cooldown_ms = 250; };
        "Mod+Page_Down" = { action = "workspace-next"; cooldown_ms = 250; };
        "Mod+WheelUp" = { action = "workspace-previous"; cooldown_ms = 250; };
        "Mod+WheelDown" = { action = "workspace-next"; cooldown_ms = 250; };

        # === Noctalia shell ===
        "Mod+S" = "spawn:noctalia msg panel-toggle control-center";
        "Alt+Tab" = "spawn:noctalia msg window-switcher";

        # === Audio (allow when locked) ===
        "XF86AudioRaiseVolume" = { action = "spawn:noctalia msg volume-up"; allow_when_locked = true; };
        "XF86AudioLowerVolume" = { action = "spawn:noctalia msg volume-down"; allow_when_locked = true; };
        "XF86AudioMute" = { action = "spawn:noctalia msg volume-mute"; allow_when_locked = true; };
        "XF86AudioMicMute" = { action = "spawn:noctalia msg mic-mute"; allow_when_locked = true; };
        "XF86AudioNext" = { action = "spawn:noctalia msg media next"; allow_when_locked = true; };
        "XF86AudioPlay" = { action = "spawn:noctalia msg media toggle"; allow_when_locked = true; };
        "XF86AudioPrev" = { action = "spawn:noctalia msg media previous"; allow_when_locked = true; };
        "XF86AudioStop" = { action = "spawn:noctalia msg media stop"; allow_when_locked = true; };

        # === Brightness (allow when locked) ===
        "XF86MonBrightnessUp" = { action = "spawn:noctalia msg brightness-up"; allow_when_locked = true; };
        "XF86MonBrightnessDown" = { action = "spawn:noctalia msg brightness-down"; allow_when_locked = true; };

        # === Power ===
        "Ctrl+Alt+Delete" = { action = "spawn:noctalia msg panel-toggle session"; repeat = false; };
        "Mod+Shift+L" = { action = "spawn:noctalia msg session lock"; repeat = false; };
        "Mod+Shift+Alt+L" = { action = "spawn:noctalia msg session lock-and-suspend"; repeat = false; };
        "Mod+Shift+Alt+Escape" = { action = "spawn:noctalia msg session shutdown"; repeat = false; };

        # === Screenshot ===
        "Print" = { action = "spawn:noctalia msg screenshot-region"; repeat = false; };
        "Ctrl+Print" = { action = "spawn:noctalia msg screenshot-fullscreen"; repeat = false; };

        # === Misc ===
        "Mod+Shift+Slash" = { action = "cheatsheet-toggle"; repeat = false; };
      };
    };
  };
}
