# Shared Syncthing: syncs dot-config folders between blackstar/shephard
# (+ future machines). Devices are declared here; folders reference them.
#
# To add a machine: add its entry under settings.devices (get its ID with
# `sudo -u drew syncthing device-id -C /home/drew/.config/syncthing -D
# /home/drew/.local/share/syncthing`, or GUI Actions > Show ID), then add
# its name to each folder's `devices` list you want it to share.
# Device IDs are public (derived from the public key) -- safe in git.
# The private key.pem/cert.pem stay local and never enter the repo.
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
        blackstar.id = "2KBR4YB-HYHDSXN-Y4AYRX7-AODVYVQ-CHGS3IG-I5CHVYZ-JD6JZ3G-LMT5SQQ";
        shephard.id = "76Y6JJV-UHZ3BUL-AYJX2LO-N7ILSXJ-2QOBBGA-MV5ITAR-UQRO6R7-3H3JMQY";
      };
      folders = {
        reaper-fxchains = {
          path = "/home/drew/.config/reaper-flake/FXChains";
          devices = [
            "blackstar"
            "shephard"
          ];
        };
        reaper-project-templates = {
          path = "/home/drew/.config/reaper-flake/ProjectTemplates";
          devices = [
            "blackstar"
            "shephard"
          ];
        };
        reaper-track-templates = {
          path = "/home/drew/.config/reaper-flake/TrackTemplates";
          devices = [
            "blackstar"
            "shephard"
          ];
        };
        reaper-tools = {
          path = "/home/drew/Projects/reaper-tools";
          devices = [
            "blackstar"
            "shephard"
          ];
        };
        # opencode config is synced as two focused folders, never the whole
        # ~/.config/opencode tree -- that would drag node_modules/ and the
        # machine-specific opencode.jsonc (which hardcodes the nix profile's
        # reaper-mcp binary path and TMPDIR) along with it.
        #
        # Folder ids are derived from these labels, and both machines apply
        # this same list, so ids and sharing stay in step automatically.
        opencode-agents = {
          path = "/home/drew/.config/opencode/agents";
          devices = [
            "blackstar"
            "shephard"
          ];
        };
        # reaper-podcast.toml: the xDarkzx Reaper-MCP tool profile. Hand-edited
        # (it tracks the MCP's module list as packages bump), so it lives on
        # its own rather than in a nix string where every tweak needs a rebuild.
        opencode-mcp = {
          path = "/home/drew/.config/opencode/mcp";
          devices = [
            "blackstar"
            "shephard"
          ];
        };
      };
    };
  };
}
