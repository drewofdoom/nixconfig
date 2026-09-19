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
      # Native Wayland Wine/Proton. Verified working on this box: games run
      # through winewayland.so and set the `proton-game` tag plus
      # content_type=game, which is what the VRR rules below key off. Without
      # this they go through winex11.so -> xwayland-satellite instead.
      # Umbriel captures [environment] at startup only -- restart Umbriel and
      # fully quit/relaunch Steam for a change to take effect, and run
      # `systemctl --user unset-environment PROTON_ENABLE_WAYLAND` if removed.
      environment.PROTON_ENABLE_WAYLAND = "1";
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
      input.mouse = {
        accel_profile = "flat";
      };
      animation = {
        windows_in = {
          style = "slide";
          curve = "bounce";
        };
        windows_out = {
          style = "slide";
          curve = "bounce";
        };
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
        radius = 2;
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
        # Default: blur everything (covers Niri's default window-rule background blur).
        # Corner radius / clipping come from appearance.corner_radius.
        {
          blur = true;
          blur_optimized = false;
        }
        # Ghostty translucency.
        {
          match.app_id = "^com.mitchellh.ghostty$";
          opacity = 0.95;
        }
        # Floating utilities (Niri app-id matches).
        {
          match.app_id = "^(org.gnome.DejaDup|Emulator|zenity|xdg-desktop-portal|org.pulseaudio.pavucontrol|dev.noctalia.Noctalia|org.gnome.Decibels)$";
          default_floating = true;
        }
        # Floating dialogs by title (Niri title matches; substring match, no anchors).
        {
          match.title = "(Picture in picture|Picture-in-Picture|AppImage Installer|Open File|Select|Choose a wallpaper|Open Folder|Save As|Library|Choose Where to Download|File Operation Progress|Rename|Copy Files|Move Files|Search Files|All Files|Save Project|Sign In)";
          default_floating = true;
        }
        # Zed open dialogs (Niri: app-id + title AND).
        {
          match.app_id = "^dev.zed.Zed$";
          match.title = "Zed —";
          default_floating = true;
        }
        # Darkest Dungeon: never fullscreen, never floating.
        # Disabled for now -- revisit if the game misbehaves on Umbriel.
        # {
        #   match.app_id = "^darkest.bin.x86_64$";
        #   default_fullscreen = false;
        #   default_floating = false;
        # }
        # Steam games under Wine's X11 driver: always VRR. `steam_app_<id>` is
        # set only by winex11.so, so under PROTON_ENABLE_WAYLAND=1 the rules
        # below are what actually fire. Kept as cheap coverage for games forced
        # back to X11 (per-game PROTON_ENABLE_WAYLAND=0) or native X11 titles.
        {
          match.app_id = "^steam_app_";
          vrr = "always";
        }
        # Proton windows tagged `proton-game`: always VRR. Separate from the
        # app_id rule above because Proton-EM (and Proton under native Wayland)
        # sets this client-defined XDG tag, which an app_id match like
        # ^steam_app_ would miss entirely. `vrr` is a dynamic setting, so it
        # re-resolves when focus changes rather than only at window open.
        {
          match.xdg_tag = "^proton-game$";
          vrr = "always";
        }
        # Catch-all for anything advertising the standardized `game` content
        # hint: native Wayland games that set neither a steam_app_* app_id nor
        # the proton-game tag. Rules contribute additively and later rules win
        # on conflicting fields, so this sits last -- it only needs to beat the
        # output's default `vrr = "disabled"`, and it agrees with the two
        # rules above where they overlap.
        {
          match.content_type = "game";
          vrr = "always";
        }
        # Steam notification toasts: bottom-right, don't steal focus.
        {
          match.app_id = "^steam$";
          match.title = "^notificationtoasts_.+_desktop";
          default_floating = true;
          default_position = {
            x = 10;
            y = 10;
            anchor = "bottom_right";
          };
          default_focused = false;
        }

        # NOTE, not ported from Niri rules.kdl:
        # - mpv 1920x1080 / AppManager+Ignition 800px / Telegram 600px fixed
        #   column widths: Umbriel tiled windows size by fraction
        #   (default_scrolling_extent), no fixed-px equivalent.
        # - layer-rule place-within-backdrop for noctalia-backdrop: no equivalent.
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
        "Mod+WheelLeft" = "layout-scroll-left";
        "Mod+WheelRight" = "layout-scroll-right";

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
        "Mod+Shift+F" = {
          action = "window-toggle-fullscreen";
          repeat = false;
        };
        "Mod+M" = "window-toggle-maximize-to-edges";

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
      };
    };
  };
}
