{ ... }:

{
  programs.umbriel.settings.window_rule = [
    # Floating utilities
    {
      match.app_id = "^(org.gnome.DejaDup|Emulator|zenity|xdg-desktop-portal|org.pulseaudio.pavucontrol|dev.noctalia.Noctalia|org.gnome.Decibels)$";
      default_floating = true;
    }
    # Umbriel Share Picker
    {
      match.app_id = "^dev.noctalia.UmbrielSharePicker$";
      default_floating = true;
    }
    # Floating dialogs by title
    {
      match.title = "(Picture in picture|Picture-in-Picture|AppImage Installer|Open File|Select|Choose a wallpaper|Open Folder|Save As|Library|Choose Where to Download|File Operation Progress|Rename|Copy Files|Move Files|Search Files|All Files|Save Project|Sign In|Preferences)";
      default_floating = true;
    }
    # Zed open dialogs
    {
      match.app_id = "^dev.zed.Zed$";
      match.title = "Zed —";
      default_floating = true;
    }
    {
      match.app_id = "^io.github.knightinfected.PipeWireControlCenter$";
      default_floating = true;
      default_scratchpad = "default";
      default_position = {
        x = 0;
        y = 0;
        anchor = "center";
      };
    }
    # Xwayland-run
    {
      match.app_id = "org.freedesktop.Xwayland";
      default_maximize = true;
    }
  ];
}
