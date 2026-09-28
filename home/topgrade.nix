# Topgrade -- one command to update everything.
#
# Home Manager's programs.topgrade writes ~/.config/topgrade.toml (topgrade's
# first-choice config path) from a structured `settings` attrset. Note there is
# no NixOS programs.topgrade -- it is home-manager only.
#
# The `nh` half of the setup lives in system/core.nix: programs.nh already
# exports NH_FLAKE system-wide, and topgrade's nh handler refuses to run without it.
{
  inputs,
  pkgs,
  ...
}:

{
  programs.topgrade = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.topgrade;
    settings = {
      commands = {
        "Run garbage collection on Nix store" = "nix-collect-garbage";
      };

      misc = {
        assume_yes = true;
        cleanup = true;
        nix_handler = "nh";

        # `git_repos` is near the END of topgrade's default step order
        # (System ~8th, GitRepos ~3rd-from-last in src/step.rs), so without
        # `first` the `nh os switch -u` build runs on the stale pre-pull
        # tree. Forcing it first keeps the build fresh.
        first = [ "git_repos" ];

        # `home_manager` runs `nh home switch`, which has no flake output
        # to build here (HM is a NixOS module, not homeConfigurations).
        disable = [
          "home_manager"
          "self_update"
        ];

        only = [
          "custom_commands"
          "firmware"
          "flatpak"
          "git_repos"
          "system"
          "pipx"
          "uv"
        ];
      };

      # `nh os switch -u` rewrites flake.lock in place. Commit + push it
      # only when it actually changed (diff --quiet exits 0 when clean,
      # so the commit/push never fires on a no-op run).
      post_commands = {
        "Sync flake.lock" =
          "sh -c 'cd $HOME/Projects/nixconfig && git diff --quiet -- flake.lock || { git add flake.lock && git commit -m \"chore: update flake.lock\" && git push; }'";
      };

      firmware = {
        upgrade = true;
      };

      linux = {
        home_manager_arguments = [ ];
      };

      git = {
        repos = [
          "~/Projects/nixconfig"
          "~/Projects/reaper-daemon"
        ];
      };
    };
  };
}
