# blackstar-only home config.

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    heroic
    protontricks
    mangohud

    # keep uv available for ad-hoc pip work
    uv
  ];

  programs.umbriel.settings = {
    # VRR is set per-output — there is no top-level vrr option.
    # DP-1 gets VRR (gaming on the ultrawide); HDMI-A-1 does not (secondary monitor).

    output = {
      "DP-1" = {
        mode = "5120x1440@75";
        position = [
          0
          0
        ];
        hdr = "auto";
        sdr_white = 400;
        vrr = "always";
      };
      "HDMI-A-1" = {
        mode = "1920x1080@60";
        position = [
          3150
          1440
        ];
        hdr = "auto";
        sdr_white = 400;
        vrr = "disabled";
      };
    };

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
    ];
  };
}
