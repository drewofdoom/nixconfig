# blackstar-only home config.

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    heroic
    protonplus
    protontricks
    mangohud

    # keep uv available for ad-hoc pip work
    uv
  ];

  programs.umbriel.settings = {
    window_rule = [
      {
        match.app_id = "^gamescope";
        vrr = "always";
        hdr = "fullscreen";
      }
      {
        match.app_id = "^steam_app_";
        vrr = "always";
      }
      {
        match.xdg_tag = "^proton-game$";
        vrr = "always";
      }
      {
        match.content_type = "game";
        vrr = "always";
      }
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
  };
}
