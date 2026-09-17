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
      include.optional.files = [ "hardware.toml" ];
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

        # === Noctalia ===
        "Mod+N" = "spawn:noctalia msg panel-toggle noctalia/notes:panel";
        "Mod+Shift+N" = "spawn:noctalia msg config-reload";

        # === Actions ===
        "Mod+D" = {
          action = "overview-toggle";
          repeat = false;
        };
        "Mod+O" = {
          action = "overview-toggle";
          repeat = false;
        };
        "Mod+C" = "column-center";
        "Mod+Shift+C" = "column-center";
        "Mod+Q" = {
          action = "window-close";
          repeat = false;
        };
        "Mod+grave" = {
          action = "scratchpad-toggle";
          repeat = false;
        };
        "Mod+Ctrl+grave" = "window-toggle-scratchpad";
        "Mod+BracketLeft" = "window-consume-or-expel-left";
        "Mod+BracketRight" = "window-consume-or-expel-right";

        # === Focus: direct workspace jumping ===
        "Mod+1" = "workspace-switch:1";
        "Mod+2" = "workspace-switch:2";
        "Mod+3" = "workspace-switch:3";
        "Mod+4" = "workspace-switch:4";
        "Mod+5" = "workspace-switch:5";
        "Mod+6" = "workspace-switch:6";
        "Mod+7" = "workspace-switch:7";
        "Mod+8" = "workspace-switch:8";
        "Mod+9" = "workspace-switch:9";

        # === Focus: workspace directional ===
        "Mod+Page_Up" = {
          action = "workspace-previous";
          cooldown_ms = 250;
        };
        "Mod+Page_Down" = {
          action = "workspace-next";
          cooldown_ms = 250;
        };
        "Mod+WheelUp" = {
          action = "workspace-previous";
          cooldown_ms = 250;
        };
        "Mod+WheelDown" = {
          action = "workspace-next";
          cooldown_ms = 250;
        };

        # === Focus: window directional (Niri ...-or-monitor-... -> ...-or-output-...) ===
        "Mod+Up" = "window-focus-or-output-up";
        "Mod+Down" = "window-focus-or-output-down";
        "Mod+Left" = "window-focus-or-output-left";
        "Mod+Right" = "window-focus-or-output-right";
        "Mod+MouseBack" = "window-focus-or-output-left";
        "Mod+MouseForward" = "window-focus-or-output-right";
        "Mod+Home" = "column-focus-first";
        "Mod+End" = "column-focus-last";
        "Mod+WheelLeft" = {
          action = "window-focus-left";
          cooldown_ms = 250;
        };
        "Mod+WheelRight" = {
          action = "window-focus-right";
          cooldown_ms = 250;
        };

        # === Move: to workspace directly ===
        "Mod+Ctrl+1" = "column-move-to-workspace:1";
        "Mod+Ctrl+2" = "column-move-to-workspace:2";
        "Mod+Ctrl+3" = "column-move-to-workspace:3";
        "Mod+Ctrl+4" = "column-move-to-workspace:4";
        "Mod+Ctrl+5" = "column-move-to-workspace:5";
        "Mod+Ctrl+6" = "column-move-to-workspace:6";
        "Mod+Ctrl+7" = "column-move-to-workspace:7";
        "Mod+Ctrl+8" = "column-move-to-workspace:8";
        "Mod+Ctrl+9" = "column-move-to-workspace:9";

        # === Move: to workspace by direction (down=next, up=previous) ===
        "Mod+Ctrl+Page_Down" = "column-move-to-workspace-next";
        "Mod+Ctrl+Page_Up" = "column-move-to-workspace-previous";
        "Mod+Ctrl+WheelDown" = {
          action = "column-move-to-workspace-next";
          cooldown_ms = 150;
        };
        "Mod+Ctrl+WheelUp" = {
          action = "column-move-to-workspace-previous";
          cooldown_ms = 150;
        };

        # === Move: window/column by direction ===
        "Mod+Ctrl+Up" = "window-move-up";
        "Mod+Ctrl+Down" = "window-move-down";
        "Mod+Ctrl+Left" = "column-move-left";
        "Mod+Ctrl+Right" = "column-move-right";
        "Mod+Ctrl+Home" = "column-move-to-first";
        "Mod+Ctrl+End" = "column-move-to-last";
        "Mod+Ctrl+WheelLeft" = "column-move-left";
        "Mod+Ctrl+WheelRight" = "column-move-right";

        # === Move: column to monitor/output by direction ===
        "Mod+Shift+Ctrl+Up" = "column-move-to-output-up";
        "Mod+Shift+Ctrl+Down" = "column-move-to-output-down";
        "Mod+Shift+Ctrl+Left" = "column-move-to-output-left";
        "Mod+Shift+Ctrl+Right" = "column-move-to-output-right";

        # === Size ===
        "Mod+F" = {
          action = "window-toggle-maximize";
          repeat = false;
        };
        "Mod+Ctrl+F" = "window-cycle-primary-extent";
        "Mod+Shift+F" = {
          action = "window-toggle-fullscreen";
          repeat = false;
        };
        "Mod+Alt+F" = "window-toggle-fullscreen";
        "Mod+M" = "window-toggle-maximize-to-edges";
        "Mod+Minus" = "window-modify-primary-extent:-0.05";
        "Mod+Equal" = "window-modify-primary-extent:0.05";
        "Mod+R" = "window-cycle-primary-extent";
        "Mod+Shift+R" = "window-cycle-primary-extent-back";
        "Mod+Ctrl+R" = "window-cycle-secondary-extent";

        # === Floating ===
        "Mod+T" = {
          action = "window-toggle-floating";
          repeat = false;
        };
        "Mod+Shift+T" = "window-focus-switch-floating";
        # Niri's toggle-column-tabbed-display has no Umbriel equivalent; Mod+W left unbound.
        # === Power (monitors) ===
        "Mod+Shift+P" = "dpms-off";

        # === Noctalia shell ===
        "Mod+S" = "spawn:noctalia msg panel-toggle control-center";
        "Alt+Tab" = "spawn:noctalia msg window-switcher";

        # === Audio (allow when locked) ===
        "XF86AudioRaiseVolume" = {
          action = "spawn:noctalia msg volume-up";
          allow_when_locked = true;
        };
        "XF86AudioLowerVolume" = {
          action = "spawn:noctalia msg volume-down";
          allow_when_locked = true;
        };
        "XF86AudioMute" = {
          action = "spawn:noctalia msg volume-mute";
          allow_when_locked = true;
        };
        "XF86AudioMicMute" = {
          action = "spawn:noctalia msg mic-mute";
          allow_when_locked = true;
        };
        "XF86AudioNext" = {
          action = "spawn:noctalia msg media next";
          allow_when_locked = true;
        };
        "XF86AudioPlay" = {
          action = "spawn:noctalia msg media toggle";
          allow_when_locked = true;
        };
        "XF86AudioPrev" = {
          action = "spawn:noctalia msg media previous";
          allow_when_locked = true;
        };
        "XF86AudioStop" = {
          action = "spawn:noctalia msg media stop";
          allow_when_locked = true;
        };

        # === Brightness (allow when locked) ===
        "XF86MonBrightnessUp" = {
          action = "spawn:noctalia msg brightness-up";
          allow_when_locked = true;
        };
        "XF86MonBrightnessDown" = {
          action = "spawn:noctalia msg brightness-down";
          allow_when_locked = true;
        };

        # === Power ===
        "Ctrl+Alt+Delete" = {
          action = "spawn:noctalia msg panel-toggle session";
          repeat = false;
        };
        "Mod+Shift+L" = {
          action = "spawn:noctalia msg session lock";
          repeat = false;
        };
        "Mod+Shift+Alt+L" = {
          action = "spawn:noctalia msg session lock-and-suspend";
          repeat = false;
        };
        "Mod+Shift+Alt+Escape" = {
          action = "spawn:noctalia msg session shutdown";
          repeat = false;
        };

        # === Screenshot ===
        "Print" = {
          action = "spawn:noctalia msg screenshot-region";
          repeat = false;
        };
        "Ctrl+Print" = {
          action = "spawn:noctalia msg screenshot-fullscreen";
          repeat = false;
        };

        # === Misc ===
        "Mod+Shift+Slash" = {
          action = "cheatsheet-toggle";
          repeat = false;
        };
        "Mod+Escape" = "shortcuts-inhibit-toggle";
      };
    };
  };
}
