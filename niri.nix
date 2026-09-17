# Niri config mirroring the Umbriel setup (Mod=Super, same launchers,
# Niri has no blur or scratchpad, so those Umbriel features are skipped.
# Noctalia writes ~/.config/niri/noctalia.kdl via its "niri" template;
# the include line below picks up its theme colors.
{ ... }:

{
  xdg.configFile."niri/config.kdl".text = ''
    include "noctalia.kdl"
    include "hardware.kdl"

    prefer-no-csd

    input {
      keyboard {
        xkb {
          layout "us"
        }
      }
      touchpad {
        tap
        dwt
        natural-scroll
        click-method "clickfinger"
        disabled-on-external-mouse
      }
    }

    layout {
      gaps 8
      center-focused-column "on-overflow"
      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }
      default-column-width { proportion 0.5; }

      focus-ring {
        width 2
      }
      border {
        width 0
      }

      tab-indicator {
        hide-when-single-tab
        place-within-column
        gap 4
        width 4
        length total-proportion=0.3
      }
    }

    cursor {
      xcursor-theme "Bibata-Modern-Ice"
      xcursor-size 24
    }

    hotkey-overlay {
      skip-at-startup
    }

    spawn-at-startup "noctalia"

    binds {
      // === Application launchers ===
      Mod+Return { spawn "ghostty"; }
      Mod+Space { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
      Mod+B { spawn "zen"; }
      Mod+E { spawn "nautilus"; }

      // === Window management ===
      Mod+D repeat=false { toggle-overview; }
      Mod+Q repeat=false { close-window; }
      Mod+F repeat=false { maximize-column; }
      Mod+Shift+F repeat=false { fullscreen-window; }
      Mod+T repeat=false { toggle-window-floating; }
      Mod+W repeat=false { toggle-column-tabbed-display; }

      // === Focus (column + window) ===
      Mod+Left { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Up { focus-window-up; }
      Mod+Down { focus-window-down; }
      Mod+Ctrl+Left { move-column-left; }
      Mod+Ctrl+Right { move-column-right; }
      Mod+Ctrl+Up { move-window-up; }
      Mod+Ctrl+Down { move-window-down; }
      Mod+Home { focus-column-first; }
      Mod+End { focus-column-last; }
      Mod+Ctrl+Home { move-column-to-first; }
      Mod+Ctrl+End { move-column-to-last; }
      Mod+R { switch-preset-column-width; }

      // === Workspaces ===
      Mod+Page_Up { focus-workspace-up; }
      Mod+Page_Down { focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
      Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Mod+Ctrl+Page_Up { move-column-to-workspace-up; }
      Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
      Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }

      // === Noctalia shell ===
      Mod+S { spawn "noctalia" "msg" "panel-toggle" "control-center"; }
      Alt+Tab { spawn "noctalia" "msg" "window-switcher"; }

      // === Audio (allow when locked) ===
      XF86AudioRaiseVolume allow-when-locked=true { spawn "noctalia" "msg" "volume-up"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn "noctalia" "msg" "volume-down"; }
      XF86AudioMute allow-when-locked=true { spawn "noctalia" "msg" "volume-mute"; }
      XF86AudioMicMute allow-when-locked=true { spawn "noctalia" "msg" "mic-mute"; }
      XF86AudioNext allow-when-locked=true { spawn "noctalia" "msg" "media" "next"; }
      XF86AudioPlay allow-when-locked=true { spawn "noctalia" "msg" "media" "toggle"; }
      XF86AudioPrev allow-when-locked=true { spawn "noctalia" "msg" "media" "previous"; }
      XF86AudioStop allow-when-locked=true { spawn "noctalia" "msg" "media" "stop"; }

      // === Brightness (allow when locked) ===
      XF86MonBrightnessUp allow-when-locked=true { spawn "noctalia" "msg" "brightness-up"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "noctalia" "msg" "brightness-down"; }

      // === Power ===
      Ctrl+Alt+Delete repeat=false { spawn "noctalia" "msg" "panel-toggle" "session"; }
      Mod+Shift+L repeat=false { spawn "noctalia" "msg" "session" "lock"; }
      Mod+Shift+Alt+L repeat=false { spawn "noctalia" "msg" "session" "lock-and-suspend"; }
      Mod+Shift+Alt+Escape repeat=false { spawn "noctalia" "msg" "session" "shutdown"; }

      // === Screenshot ===
      Print repeat=false { spawn "noctalia" "msg" "screenshot-region"; }
      Ctrl+Print repeat=false { spawn "noctalia" "msg" "screenshot-fullscreen"; }

      // === Session ===
      Mod+Shift+E { quit; }
      Mod+Shift+Slash repeat=false { show-hotkey-overlay; }
    }

    window-rule {
      geometry-corner-radius 10
      clip-to-geometry true
    }

    window-rule {
      match app-id="dev.noctalia.Noctalia"
      open-floating true
    }
  '';
}
