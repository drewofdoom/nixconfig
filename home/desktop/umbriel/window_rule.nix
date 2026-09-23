{ ... }:

{
  programs.umbriel.settings.window_rule = [
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
    # Xwayland-run
    {
      match.app_id = "org.freedesktop.Xwayland";
      default_maximize = true;
    }
  ];
}
