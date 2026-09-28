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
        # `nix` + `system` go through `nh os switch` instead.
        disable = [
          "home_manager"
          "self_update"
        ];

        only = [
          "custom_commands"
          "firmware"
          "flatpak"
          "git_repos"
          "pipx"
          "system"
          "uv"
        ];
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
        ];
      };
    };
  };
}
