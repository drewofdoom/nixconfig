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
    # VRR enabled globally: the RTX 3080 + DP connection handles it silently,
    # and the AOC panel has no known flicker issues at typical gaming framerates.
    # The old per-app rules are replaced by a single output-level VRR default.
    # Without `vrr = "always"`, Umbriel uses "adaptive" by default on capable
    # displays, but the output must specifically opt in or out in the config.
    output = {
      "DP-1" = {
        mode = "5120x1440@75";
        position = [
          0
          0
        ];
        hdr = "auto";
        vrr = "always";
      };
      "HDMI-A-1" = {
        mode = "1920x1080@60";
        position = [
          3150
          1440
        ];
        hdr = "auto";
        vrr = "disabled";
      };
    };

    window_rule = [
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
