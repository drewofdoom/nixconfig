# Per-host Hermes settings for blackstar.
#
# There is deliberately NO `services.hermes-agent` block here any more. It used
# to carry `backend.mode = "serve"` on :9119, which is what started the
# dashboard. That option group is disabled in home/hermes.nix (see the long note
# there for the two-unit fight and the .env-rewriting trap that motivated it),
# so the :9119 dashboard does not run on this machine. The CLI is unaffected: it
# comes from `programs.hermes-agent` in home/hermes.nix.
#
# If you want the dashboard back, run `hermes serve` yourself -- as a service you
# own, not one the module writes -- and set dashboard.public_url to match.
#
# Everything below already lives in ~/.hermes/config.yaml on disk, which Hermes
# owns and edits freely. Verify with `hermes config get <key>` and change
# anything missing with `hermes config set`:
#
#   platform_toolsets.cli         -> the toolset list for CLI sessions
#   gateway.multiplex_profiles    -> true: one gateway serves every profile
#   a2a_agents.<name>             -> outbound peer agents (rosie, ...)
#
# On a2a_agents.<name>.auth.token: keep it a REAL token, set with
# `hermes config set`. Do NOT write the literal string "${A2A_ROSIE_TOKEN}" --
# nothing interpolates it. plugins/platforms/a2a/tools.py reads auth["token"]
# verbatim into the Authorization header (_auth_header, line 48). That was
# already true before, and it only looked like it worked because an env merge
# happened to supply the value.
#
# Per-profile credentials (Telegram/Discord) go in
# ~/.hermes/profiles/<name>/.env, one copy per profile. Under multiplexing a
# profile turn does NOT fall back to the process environment
# (secret_scope.py:236, get_secret), so a profile with an empty .env sees no
# key at all and re-prompts for one. Two profiles sharing one credential is
# refused outright: "one credential cannot be consumed twice".
#
# If you ever declare an MCP server, note that bare `nix` is not on the PATH of
# a Hermes-run process -- it fails with "missing executable 'nix'". Use an
# absolute path.
{ ... }:

{ }
