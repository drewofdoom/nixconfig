# blackstar-only home config.
#
# The `backend` block exposes this instance's Hermes on the tailnet so a
# Hermes Desktop on another machine can attach to it as a remote gateway.
#
# `serve` gives the /api/ws and /api/pty sockets without a browser UI, which
# is what a remote Desktop needs. It shares one HERMES_HOME with the messaging
# gateway, so sessions, memory, skills and cron are the same on both sides
# rather than duplicated per machine.
#
# Bound to the MagicDNS FQDN, NOT 0.0.0.0. The server rejects any request whose
# Host header differs from the bind address (DNS-rebinding defense,
# GHSA-ppp5-vxwm-4cf7), and a wildcard bind disables that check entirely.
# Clients must use this exact hostname, which is also declared as
# dashboard.public_url below so Host and WS Origin validation agree.
#
# waitFor = "hostname" polls until MagicDNS resolves: tailscaled is a system
# unit and a systemd *user* unit cannot order itself after it, so a dependency
# there would be a silent no-op.
#
# A non-loopback bind REQUIRES an auth provider -- without one the backend fails
# closed at startup, and --insecure is a deprecated no-op since the June 2026
# hardening. Credentials come per-machine from ~/.config/hermes/env (wired via
# environmentFiles in home/hermes.nix):
#   HERMES_DASHBOARD_BASIC_AUTH_USERNAME
#   HERMES_DASHBOARD_BASIC_AUTH_PASSWORD
#   HERMES_DASHBOARD_BASIC_AUTH_SECRET   (restart-stable sessions)
# Deliberately not in this repo: a Nix expression is world-readable in /nix/store.

{ ... }:

{
  imports = [
    ./backup.nix
    ./home/packages.nix
    ./home/gaming.nix
    ./home/umbriel.nix
  ];

  services.hermes-agent = {
    backend = {
      mode = "serve";
      host = "blackstar.bunny-octatonic.ts.net";
      port = 9119;
      waitFor = "hostname";
    };

    settings = {
      dashboard.public_url = "http://blackstar.bunny-octatonic.ts.net:9119";

      # Outbound A2A client tools (a2a_call/discover/list/history/orchestrate).
      # `a2a` is in the runtime's _DEFAULT_OFF_TOOLSETS, so the global
      # toolsets: [ "all" ] below does NOT turn it on — it needs an explicit
      # per-platform list, and `hermes tools enable` can't write it here
      # ("this Hermes installation is managed by home-manager"). Naming the
      # composite `hermes-cli` keeps the CLI default toolset; adding `a2a`
      # opts into the default-off plugin toolset (#81163).
      platform_toolsets.cli = [ "hermes-cli" "a2a" ];

      # blackstar is the A2A *client* here; rosie serves. Explicitly disable
      # the inbound platform: an earlier edit enabled it on blackstar, which
      # bound a listener on this host for no benefit. The module preserves
      # agent-written keys across rebuilds, so removing the block from Nix
      # does NOT clear it — `hermes config unset` is also blocked under
      # home-manager. Setting it false here is what actually wins.
      gateway.platforms.a2a.enabled = false;

      # Peer to call.
      a2a_agents.rosie = {
        url = "http://rosie:9900";
        # Interpolated from ~/.config/hermes/env (merged into ~/.hermes/.env
        # at activation) so the token never lands in the world-readable store.
        # `type` is load-bearing: tools.py:49 only emits the Authorization
        # header when type == "bearer", so omitting it sends the call
        # unauthenticated rather than erroring.
        auth = {
          type = "bearer";
          token = "\${A2A_ROSIE_TOKEN}";
        };
        timeout = 120;
      };
    };
  };
}