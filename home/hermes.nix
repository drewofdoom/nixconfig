# Hermes Agent (NousResearch/hermes-agent) — shared across all hosts via home/.
#
# Docs: https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup/
#
# Two option groups:
#   programs.hermes-agent — installs the `hermes` CLI and exports HERMES_HOME
#   services.hermes-agent — owns ~/.hermes (config.yaml, .env, memories,
#                           sessions, cron) and runs the user services
#
# Gateway is ON, so add your API keys below (see environmentFiles note).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Per-host API keys, deliberately NOT in this repo. This path is identical on
  # every host but the file contents are not — each machine gets its own key, so
  # neither machine can spend the other's quota and revoking one leaves the other
  # working. Back the file up somewhere that is not this git repo.
  #
  # Create it once per machine (the `cat > file` form avoids the key ever
  # landing in shell history, unlike install -m600 /dev/stdin with a heredoc):
  #
  #   cat > ~/.config/hermes/env <<'EOF'
  #   OPENROUTER_API_KEY=sk-or-...
  #   EOF
  #   chmod 0600 ~/.config/hermes/env
  #
  # The path is checked at eval time so a missing file skips the option rather
  # than failing the rebuild. Nothing is written to ~/.hermes/.env without it,
  # and the gateway will start but fail to authenticate until it exists.
  envPath = "${config.home.homeDirectory}/.config/hermes/env";
  haveKeys = builtins.pathExists envPath;
in
{
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  programs.hermes-agent = {
    enable = true;
    desktop.enable = true;
  };

  services.hermes-agent = {
    enable = true;

    # Messaging gateway (Telegram/Discord/Slack) as a systemd *user* service.
    # Requires linger or it stops at logout:
    #   sudo loginctl enable-linger drew
    gateway.enable = true;

    # Rendering to ~/.hermes/config.yaml. Nix keys win; keys the agent writes
    # itself are preserved across rebuilds.
    settings = {
      model.default = "anthropic/claude-sonnet-4";
      toolsets = [ "all" ];
      terminal = {
        backend = "local";
        timeout = 180;
      };
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };
    };

    # Agent workspace is your home dir by default.
    workingDirectory = "/home/drew";

    # System binaries the agent can shell out to.
    extraPackages = with pkgs; [
      jq
      pandoc
    ];

    # Messaging platform deps are a build-time extra on Nix (no runtime pip).
    extraDependencyGroups = [ "messaging" ];

    # Secrets: merged into ~/.hermes/.env at activation time, so a rebuild is
    # the only thing needed after an edit (plus a service restart). Never put
    # keys in Nix expressions — they land in the world-readable /nix/store.
    environmentFiles = lib.optionals haveKeys [ envPath ];
  };
}
