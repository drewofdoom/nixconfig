# REAPER core configuration, declaratively via reaper-flake.
#
# reaper-flake owns REAPER's resource dir (~/.config/reaper-flake by default)
# and merges only the values declared here, leaving the rest of REAPER's
# mutable state alone. It also packages REAPER, SWS and a patched ReaPack, so
# the old nixpkgs reaper-{sws,reapack}-extension symlinks are gone.
#
# This file holds the parts that don't belong to a section (enablement and
# the runtime libraries REAPER dlopens) and imports everything else:
#   preferences/           -- one file per preferences group (see its default.nix)
#   mcp.nix                -- xDarkzx reaper-mcp server + Lua bridge
#   extensions.nix         -- ReaPack repositories and SWS
#   actions.nix            -- action-list script registrations
#   key-bindings.nix       -- REAPER key bindings
#   reapack-repos.nix      -- ReaPack repository list (data, imported by
#                             extensions.nix)
#
# reasonus-native/ stays a sibling of this directory: it is a self-contained
# extension build (source + calibration scripts + its own module), not part of
# the REAPER settings graph.
{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./preferences
    ./mcp.nix
    ./extensions.nix
    ./actions.nix
    ./key-bindings.nix
    inputs.reaper-flake.homeModules.reaper
  ];

  programs.reaper = {
    enable = true;
    experimental.swell-wayland.enable = false;

    # Runtime shared libraries REAPER needs from the store (SWELL/X11 stack).
    packages = with pkgs; [
      freetype
      libpng
      zlib
      fontconfig
      libepoxy
      gtk3
      cairo
      glib
    ];
  };
}
