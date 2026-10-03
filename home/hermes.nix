# Hermes Agent (NousResearch/hermes-agent) — shared across all hosts via home/.
#
# Docs: https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup/
#
# Nix installs the CLI and the desktop app. It does NOT run the gateway.
#
#   programs.hermes-agent — the `hermes` CLI, the desktop app, HERMES_HOME
#   services.hermes-agent  — DISABLED. Hermes owns its own services.
#
# Gateway is OFF here on purpose — see the note below the `in` for the three
# failures that motivated it. Secrets are NOT managed here at all; ~/.hermes
# belongs to Hermes.
{
  # config,
  pkgs,
  inputs,
  ...
}:

# let
# 2026-10-03 — why `services.hermes-agent` is disabled
# ====================================================
#
# Enabling the module's services alongside Hermes' own service management made
# two units fight over one gateway:
#
#   1. `gateway.enable = true` wrote hermes-agent.service. Hermes' own
#      `hermes gateway install` had already written hermes-gateway.service.
#      Both were enabled. The Nix one started, found the other already serving,
#      and exited 75 -- TEMPFAIL, meaning "nothing to start". Its unit sets
#      Restart=always with RestartSec=5, so systemd restarted it forever: 109
#      restarts and climbing, burning CPU in the background at all times, and
#      every `hermes` command printed a confusing "already serves profile"
#      message while it did so.
#
#   2. The activation script REWRITES ~/.hermes/.env from scratch on every
#      rebuild -- `install -m <mode> <base> .env` then appends each
#      environmentFiles entry (moduleCommon.nix:770-777). Anything Hermes wrote
#      there was destroyed by the next rebuild. The GUI and `hermes setup` both
#      offer to save platform tokens there, so that is exactly where they went.
#      This cost real credentials twice.
#
#      Editing the source secrets file did not rescue them either. Nix hashes
#      the *path* named in environmentFiles, not its contents, so an edited
#      file produced an identical store path; home-manager correctly decided
#      there was nothing to do, and home-manager-drew.service (Type=oneshot,
#      RemainAfterExit) stayed active-exited without re-running
#      hermesAgentSetup. Rebuilding lost the secrets; not rebuilding did
#      nothing. Both branches lost them.
#
#   3. The module hardcodes HERMES_MANAGED=home-manager into the systemd units
#      and the desktop wrapper via makeWrapper --set, and writes a
#      ~/.hermes/.managed marker, with no option to opt out. Hermes then
#      refuses `hermes config set` and the settings panes. Escaping that needed
#      a HERMES_MANAGED=false line in ~/.hermes/.env purely to fight the
#      module -- which then had to be re-added after every .env rewrite.
#
# Disabling the service removes all three at once: no second unit, no .env
# rewriting, and no managed lock. Hermes manages itself, which is also what its
# own docs recommend -- the Nix flake "replaces all of" the installer's runtime
# management, and after that the standard CLI workflow applies.
#
# CONSEQUENCE -- after any change to Hermes itself, run these yourself:
#
#   hermes gateway install     # (re)write the systemd user service
#   hermes gateway restart     # apply it
#
# Also note: `backend.mode = "serve"` used to live in
# hosts/blackstar/home/hermes.nix under `services.hermes-agent`, so the
# dashboard on :9119 goes away with the service. The CLI is unaffected --
# `programs.hermes-agent` is a separate option group.
#
# Why ~/.hermes/.env is not built by Nix
# ======================================
#
# See (2) above: the module owns that file and destroys foreign keys on every
# activation. So ~/.hermes is now entirely Hermes-owned. Put every key there
# directly (mode 0600), including:
#
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

  # `extraPackages` lived under `services.hermes-agent` and only reached the
  # interactive shell via `lib.mkIf cfg.enable`
  # (homeManagerModules.nix:360-362). With the service disabled, that gate
  # closes and these tools would silently vanish from the shell -- so they are
  # declared here instead. Same packages, same effect, and they no longer
  # depend on a service that is not running.
  home.packages = with pkgs; [
    jq
    pandoc
    ffmpeg
    ripgrep
  ];
}
