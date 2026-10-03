{ ... }:

{
  services.hermes-agent = {
    backend = {
      mode = "serve";
      host = "blackstar.bunny-octatonic.ts.net";
      port = 9119;
      waitFor = "hostname";
    };

    # No `settings` block any more: ~/.hermes/config.yaml is owned by Hermes (see
    # home/hermes.nix for why). Everything below still lives in config.yaml on
    # disk -- the module's merge preserves agent-written keys, and the previous
    # activations already wrote these in. They are listed here only so the
    # hand-migration is unambiguous. Verify with `hermes config get <key>` and
    # add anything missing with `hermes config set`:
    #
    #   dashboard.public_url = "http://blackstar.bunny-octatonic.ts.net:9119"
    #   platform_toolsets.cli = [ "hermes-cli" "a2a" ]
    #   gateway.platforms.a2a.enabled = false
    #   mcp_servers.nixos = { command = "nix"; args = [ "run" "github:utensils/mcp-nixos" "--" ]; }
    #   a2a_agents.rosie = { url = "..."; auth = { type = "bearer"; token = "..."; }; timeout = 300; }
    #
    # On a2a_agents.rosie.auth.token specifically: it is currently the LITERAL
    # string "${A2A_ROSIE_TOKEN}" in config.yaml, never a real secret. Nothing
    # interpolates it -- plugins/platforms/a2a/tools.py reads auth["token"]
    # verbatim into the Authorization header (_auth_header, line 48). That was
    # already true before this change; it only looked like it worked because the
    # env merge ran. Set the real token with `hermes config set` (or edit
    # config.yaml directly) and keep it out of Nix.
    #
    # Note mcp_servers.nixos invokes bare `nix`, which the hermes systemd units
    # do not have on PATH -- it fails with "missing executable 'nix'" at gateway
    # start. Use an absolute path if you want that server to come up.
  };
}
