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
}
