{ ... }:

{
  programs.umbriel.settings = {
    # input.touch = {
    #   enabled = true;
    #   map_to_output = "HDMI-1";
    # };
    window_rule = [
      {
        match.title = "^notificationtoasts_.+_desktop";
        default_floating = true;
        default_position = {
          x = 10;
          y = 10;
          anchor = "bottom_right";
        };
        default_focused = false;
        default_pinned = true;
      }
      {
        match.app_id = "stalker2-win64-shipping.exe";
        hdr = "on";
      }
    ];
  };
}
