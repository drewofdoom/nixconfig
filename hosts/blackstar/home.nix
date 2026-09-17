# blackstar-only home packages (gaming machine).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    heroic
    protonplus
    protontricks
    gamescope
    mangohud
  ];
}
