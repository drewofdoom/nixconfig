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
    output = {
      DP-1 = {
        mode = "5120x1440@75";
        position = [
          0
          0
        ];
        scale = 1.0;
        vrr = "fullscreen";
        hdr = "auto";
      };
      HDMI-A-1 = {
        mode = "1920x1080@60.000";
        position = [
          3150
          1440
        ];
        scale = 1.0;
      };
    };
  };
}
