# Topgrade -- one command to update everything.
#
# Home Manager's programs.topgrade writes ~/.config/topgrade.toml (topgrade's
# first-choice config path) from a structured `settings` attrset. Note there is
# no NixOS programs.topgrade -- it is home-manager only.
#
# The `nh` half of the setup lives in system/core.nix: programs.nh already
# exports NH_FLAKE system-wide, and topgrade's nh handler refuses to run without it.
{
  ...
}:

{
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        # Pull git before anything else. Without this, the `system` step runs
        # early in topgrade's default order and `nh os switch -u` would build
        # whatever is in the working tree rather than the freshly pulled config.
        # The step's config name is `git_repos`, not `git`.
        first = [ "git_repos" ];
        # Home Manager is wired as a NixOS module here (see flake.nix), so the
        # flake exposes no homeConfigurations and `nh home switch` has no target.
        disable = [ "home_manager" ];
        # System step runs `nh os switch -u` instead of
        # `nixos-rebuild switch --upgrade`. `-u` updates flake.lock first.
        #
        # Belongs in [misc], not [linux]: that is where topgrade 17.5.1
        # (nixos-26.05) reads it, and it moved to `linux.nix_handler` in a later
        # release. Topgrade deserializes with deny_unknown_fields, so a wrong
        # table is fatal -- but it only *warns*, then runs on a blank config, so
        # re-check the table when topgrade is bumped.
        nix_handler = "nh";
      };

      git = {
        # nixconfig (the flake) and reaper-daemon. `~/Projects/*` is a glob --
        # topgrade expands it and pulls each repo it finds.
        repos = [ "~/Projects/*" ];
        pull_predefined = true;
        # Pulls are `git pull --ff-only --recurse-submodules` (topgrade's
        # built-in behaviour), so a dirty tree fails the step instead of merging.
      };
    };
  };
}
