# Shared Syncthing: syncs dot-config folders between blackstar/shephard
# (+ future machines). Devices are declared here; folders reference them.
#
# To add a machine: add its entry under settings.devices (get its ID from
# the Syncthing GUI Actions > Show ID, or `syncthing --device-id` as user
# drew), then add its name to each folder's `devices` list you want it to
# share. Device IDs below are placeholders until first run -- replace with
# real IDs after `nh os switch` on each host.
{ ... }:

{
  services.syncthing = {
    enable = true;
    user = "drew";
    dataDir = "/home/drew/.local/share/syncthing";
    configDir = "/home/drew/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        blackstar.id = "REPLACE-WITH-BLACKSTAR-ID";
        shephard.id = "REPLACE-WITH-SHEPHARD-ID";
      };
      folders = {
        reaper-fxchains = {
          path = "/home/drew/.config/reaper-flake/FXChains";
          devices = [ "blackstar" "shephard" ];
        };
        reaper-project-templates = {
          path = "/home/drew/.config/reaper-flake/ProjectTemplates";
          devices = [ "blackstar" "shephard" ];
        };
        reaper-track-templates = {
          path = "/home/drew/.config/reaper-flake/TrackTemplates";
          devices = [ "blackstar" "shephard" ];
        };
        opencode = {
          path = "/home/drew/.config/opencode";
          devices = [ "blackstar" "shephard" ];
        };
      };
    };
  };
}
