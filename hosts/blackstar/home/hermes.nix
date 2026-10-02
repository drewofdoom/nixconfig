{ ... }:

{
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
      platform_toolsets.cli = [
        "hermes-cli"
        "a2a"
      ];

      # blackstar is the A2A *client* here; rosie serves. Explicitly disable
      # the inbound platform: an earlier edit enabled it on blackstar, which
      # bound a listener on this host for no benefit. The module preserves
      # agent-written keys across rebuilds, so removing the block from Nix
      # does NOT clear it — `hermes config unset` is also blocked under
      # home-manager. Setting it false here is what actually wins.
      gateway.platforms.a2a.enabled = false;

      # Peer to call.
      a2a_agents.rosie = {
        url = "http://rosie.bunny-octatonic.ts.net:9900";
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
