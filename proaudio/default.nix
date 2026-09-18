# Pro-audio setup, all hosts: REAPER + extensions.
# Plugin packages (nixpkgs + GitHub) live in ./plugins.
{ config, pkgs, ... }:

{
  imports = [ ./plugins ];

  home.packages = with pkgs; [
    reaper
    reaper-sws-extension
    reaper-reapack-extension
  ];

  # Reaper only loads extensions from its resource dir -- link the Nix-built
  # ones in (ReaPack can still write downloaded extensions alongside these).
  xdg.configFile = {
    "REAPER/UserPlugins/reaper_sws-x86_64.so".source =
      "${pkgs.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so";
    "REAPER/UserPlugins/reaper_reapack-x86_64.so".source =
      "${pkgs.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so";
    "REAPER/Scripts/sws_python.py".source = "${pkgs.reaper-sws-extension}/Scripts/sws_python.py";
    "REAPER/Scripts/sws_python64.py".source = "${pkgs.reaper-sws-extension}/Scripts/sws_python64.py";
  };
}
