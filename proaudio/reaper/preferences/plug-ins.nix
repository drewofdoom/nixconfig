# REAPER plugin preferences: format search paths and preset pin handling.
#
# The search path lists are REAPER's own (`[reaper].vstpath` and friends) plus
# conventional per-user locations. Nix-managed plugins install to
# $out/lib/<format> and appear in ~/.nix-profile/lib/<format> via
# `home.packages` (see ../../../plugins.nix), which is already listed here --
# so no extra search paths are needed for them.
#
# Note the VST list deliberately carries `vst3` but not `vst` under
# ~/.nix-profile (and the multi-user profile lists only `vst`): that is the
# hand-tuned set, not an oversight.
{
  ...
}:

{
  programs.reaper.preferences.plugIns = {
    clap.searchPaths = [
      "/etc/profiles/per-user/drew/lib/clap"
      "~/.nix-profile/lib/clap"
      "/run/current-system/sw/lib/clap"
      "/usr/local/lib/clap"
      "/usr/lib/clap"
      "~/.clap"
      "%CLAP_PATH%"
    ];
    lv2.searchPaths = [
      "/etc/profiles/per-user/drew/lib/lv2"
      "~/.nix-profile/lib/lv2"
      "/run/current-system/sw/lib/lv2"
      "/usr/lib/lv2"
      "/usr/local/lib/lv2"
      "~/.lv2"
    ];
    preservePinMappingsWhenLoadingPresets = false;
    vst.searchPaths = [
      "/etc/profiles/per-user/drew/lib/vst"
      "~/.nix-profile/lib/vst3"
      "/run/current-system/sw/lib/vst"
      "/run/current-system/sw/lib/vst3"
      "/usr/local/lib/vst"
      "/usr/local/lib/vst3"
      "/usr/lib/vst"
      "/usr/lib/vst3"
      "~/.vst"
      "~/.vst3"
    ];
  };
}
