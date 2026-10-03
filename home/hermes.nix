# Hermes Agent (NousResearch/hermes-agent) — shared across all hosts via home/.
#
# Docs: https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup/
#
# Two option groups:
#   programs.hermes-agent — installs the `hermes` CLI and exports HERMES_HOME
#   services.hermes-agent — owns ~/.hermes (config.yaml, .env, memories,
#                           sessions, cron) and runs the user services
#
# Gateway is ON. Secrets are NOT managed here any more — see the note below the
# `in` for why, and for the one line you must add to ~/.hermes/.env yourself.
{
  # config,
  pkgs,
  inputs,
  ...
}:

# let
  # Why ~/.hermes/.env is no longer built by Nix
  # ==========================================
  #
  # This file used to point `environmentFiles` at ~/.config/hermes/env and treat
  # that as the single source of truth for secrets. That was a trap, and it cost
  # real credentials twice before this was removed:
  #
  #   1. The module REWRITES ~/.hermes/.env from scratch on every activation --
  #      `install -m <mode> <base> .env` followed by appending each
  #      environmentFiles entry (moduleCommon.nix:770-777, called at
  #      moduleCommon.nix:882). Anything Hermes itself wrote to .env was
  #      destroyed by the next rebuild. The GUI and `hermes setup` both offer to
  #      save platform tokens there, so that is exactly where they went.
  #
  #   2. Editing the secrets file did NOT reliably cause a rebuild to run, either.
  #      Nix hashes the *path* named in environmentFiles, not its contents, so an
  #      edited file produces an identical store path. `nh os switch` would
  #      correctly decide there was nothing to do, and home-manager-drew.service
  #      (Type=oneshot, RemainAfterExit) would stay active-exited without
  #      re-running hermesAgentSetup.
  #
  # Net effect: a rebuild deleted your tokens, and not rebuilding did nothing.
  # Both branches lost the secrets.
  #
  # So ~/.hermes/.env is now entirely Hermes-owned. Put every key there directly
  # (mode 0600), including:
  #
  #   HERMES_MANAGED=false        <- REQUIRED, see below
  #   OPENROUTER_API_KEY=sk-or-...
  #   TELEGRAM_BOT_TOKEN=...      <- else "No messaging platforms enabled"
  #   DISCORD_BOT_TOKEN=...       <- same
  #
  # NEVER put these in a Nix expression: they land in the world-readable
  # /nix/store.
  #
  # Each multiplexed profile needs its own copy under
  # ~/.hermes/profiles/<name>/.env. Under multiplexing a profile turn resolves
  # credentials from that profile's own .env and deliberately does NOT fall back
  # to the process environment (secret_scope.py:236, get_secret), so a profile
  # with an empty .env sees no key at all and re-prompts for one. That is not a
  # Nix artifact and is unaffected by this change.
  #
  # The old per-host file ~/.config/hermes/env is no longer read by anything and
  # can be deleted once its keys are copied into ~/.hermes/.env. Keep it out of
  # git either way.
# in
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

    # No `settings` block: ~/.hermes/config.yaml is owned by Hermes.
    #
    # This was not always so, and the reasons are worth keeping, because they
    # are the reason to leave it alone:
    #   display.personality is owned by the settings pane; pinning it re-asserted
    #   the old value every activation so the GUI could never change it.
    #   The `model` block is worse: the desktop picker writes model.default AND
    #   model.provider as a pair (model_switch.py:1783). Pinning provider would
    #   deep-merge "openrouter" back over the app's pick, leaving a provider
    #   that no longer matches the chosen model -- provider is authoritative at
    #   dispatch and is never re-derived from the model name
    #   (runtime_provider.py:478).
    #
    # Note the module still deep-merges `terminal.cwd` (from workingDirectory
    # below) and `_config_version` into config.yaml on every activation -- that
    # happens unconditionally and cannot be switched off short of setting
    # `configFile`. Every other key is now the application's alone.

    # Agent workspace is your home dir by default.
    workingDirectory = "/home/drew";

    # System binaries the agent can shell out to.
    extraPackages = with pkgs; [
      jq
      pandoc
    ];

    # Messaging platform deps are a build-time extra on Nix (no runtime pip).
    extraDependencyGroups = [ "messaging" ];

    # No `environment` and no `environmentFiles`. See the note at the top of this
    # file: the module rewrites ~/.hermes/.env on every activation, so anything
    # not named here was destroyed on each rebuild.
    #
    # CONSEQUENCE -- you must add this line to ~/.hermes/.env yourself:
    #
    #   HERMES_MANAGED=false
    #
    # The module hardcodes HERMES_MANAGED=home-manager into the systemd unit and
    # the desktop wrapper via makeWrapper --set, and also writes a ~/.hermes/.managed
    # marker, with no option to opt out. Hermes refuses `hermes config set` and the
    # settings panes while either says "managed". The false/0/no/off value read by
    # _MANAGED_FALSE_VALUES (hermes_constants.py:779) is the escape hatch, and
    # ~/.hermes/.env is loaded with override=True at import time (env_loader.py:507),
    # ahead of every is_managed() gate -- so it beats the systemd Environment= line
    # and short-circuits the marker.
    #
    # This used to be set through the `environment` option, which made it survive
    # regeneration. Now that .env is Hermes-owned, that line is durable on its own:
    # nothing rewrites the file, so it persists until Hermes itself edits it.
  };
}
