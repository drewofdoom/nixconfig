{ ... }:

{
  programs.umbriel.window_rule = [
    # Ghostty translucency.
    {
      match.app_id = "^com.mitchellh.ghostty$";
      opacity = 0.95;
      blur = true;
      blur_optimized = false;
    }
    # Floating utilities
    {
      match.app_id = "^(org.gnome.DejaDup|Emulator|zenity|xdg-desktop-portal|org.pulseaudio.pavucontrol|dev.noctalia.Noctalia|org.gnome.Decibels)$";
      default_floating = true;
    }
    # Floating dialogs by title
    {
      match.title = "(Picture in picture|Picture-in-Picture|AppImage Installer|Open File|Select|Choose a wallpaper|Open Folder|Save As|Library|Choose Where to Download|File Operation Progress|Rename|Copy Files|Move Files|Search Files|All Files|Save Project|Sign In)";
      default_floating = true;
    }
    # Zed open dialogs
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

  ];
}
