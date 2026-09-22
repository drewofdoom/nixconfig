# REAPER MCP servers, declaratively via reaper-flake mechanisms.
#
# Two servers (both load-bearing, see opencode/REAPER.md for the division of
# labor): xDarkzx `reaper-mcp` (PyPI 0.8.1, with [analysis] extras) and the
# local `reaper-daemon` checkout (stdlib-only `reaper_mcp.py`, referenced live
# so the working tree stays the source of truth for the Python side).
#
# REAPER-side loaders are installed WITHOUT hand-editing the resource dir:
# - Lua files land in Scripts/ via `programs.reaper.resourceFiles.files`
#   (whole-file mechanism, same as the flake's own reapack-startup.lua).
# - `programs.reaper.lineFiles.files."Scripts/__startup.lua"` APPENDS our
#   dofile lines alongside the flake's ReaPack/SWS hooks (additive, with
#   previous-generation cleanup). Never edit __startup.lua by hand.
# - Both bridges are also registered in `programs.reaper.actions.scripts`
#   so they can be (re)run from REAPER's action list.
#
# Daemon bridge, vendored from the live checkout (pure evaluation forbids
# absolute paths). Re-copy after bridge changes:
#   cp ~/Projects/reaper-daemon/bridge/{reaper_agent_bridge,json}.lua proaudio/reaper-lua/
# Currently at bridge v3.21.0. Disk-write gates stay live in the checkout
# at bridge/bridge_config.json (currently all open).
{
  pkgs,
  ...
}:

let
  # Not in nixpkgs 26.05; simple PyPI build (deps: scipy, numpy).
  pyloudnorm = pkgs.python3Packages.buildPythonPackage rec {
    pname = "pyloudnorm";
    version = "0.2.0";
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-i/WXZY6k4ZdcJ1rfSQ9t61Np6kCfKQH5OZFe+ktoGxY=";
    };
    pyproject = true;
    build-system = with pkgs.python3Packages; [ setuptools ];
    dependencies = with pkgs.python3Packages; [
      scipy
      numpy
    ];
    doCheck = false;
  };

  # Pinned per MEMORY.md (2026-09-21): xdarkzx-reaper-mcp 0.8.1.
  xdarkzx-reaper-mcp = pkgs.python3Packages.buildPythonApplication rec {
    pname = "xdarkzx-reaper-mcp";
    version = "0.8.1";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/38/ea/d95e3526561daef391246daa60e035b15296f2433e300afa16a1046b3537/xdarkzx_reaper_mcp-0.8.1.tar.gz";
      sha256 = "sha256-yEKP72PCIwtFI4Z//MXUKH7Z1kOB04aJqe3Ma2ea+Ws=";
    };
    pyproject = true;
    build-system = with pkgs.python3Packages; [ hatchling ];
    # Runtime deps: mcp[cli]<2.0 (upstream pins <2.0: 2.x removed
    # mcp.server.fastmcp) + the [analysis] extras (numpy/soundfile/pyloudnorm).
    dependencies = with pkgs.python3Packages; [
      mcp
      typer
      rich
      numpy
      soundfile
      pyloudnorm
    ];
    # No network in sandbox; skip tests that shell out / need REAPER.
    doCheck = false;
  };

  # reaper_mcp_server.lua is NOT in the PyPI bundle; pin the matching tag.
  reaper-mcp-lua = pkgs.fetchFromGitHub {
    owner = "xDarkzx";
    repo = "Reaper-MCP";
    rev = "92be0fe468ba22b3df28c9a51ba1d54b2eb2c6b0"; # v0.8.1
    hash = "sha256-/4le3j/DGFzxyk7qqwBaMilCIlEe5pZcTUatIV3fvJA=";
  };

  # Daemon bridge from the vendored copies (see note above).
  daemonBridgeFile = name: ./reaper-lua/${name};

  # Daemon startup block: mirrors setup/install.py's managed block (bridge
  # load + stale-lock watchdog), but resolves paths through REAPER's resource
  # dir so the flake owns the files.
  daemonStartup = pkgs.writeText "reaper-daemon-startup.lua" ''
    do
      -- Prefer the live checkout (json.lua, bridge_config.json with the open
      -- disk-write gates, and logs/ all resolve there). The vendored copies
      -- under Scripts/reaper-daemon/ are fallback only.
      local live_dir = "/home/drew/Projects/reaper-daemon/bridge"
      local vendored_file = reaper.GetResourcePath() .. "/Scripts/reaper-daemon/reaper_agent_bridge.lua"
      local repo_root = "/home/drew/Projects/reaper-daemon"
      local lockfile = repo_root .. "/logs/bridge.lock"
      local RENDER_LOCK_MAX_AGE = 6 * 3600

      local function read_lock()
        local f = io.open(lockfile, "r")
        if not f then return nil end
        local content = f:read("*a")
        f:close()
        local started = tonumber(content:match('"started"%s*:%s*(%d+)'))
          or tonumber(content:match("^%s*(%d+)%s*$"))
        local busy = content:match('"busy"%s*:%s*"([^"]+)"') or "none"
        if not started then return nil end
        return { started = started, busy = busy }
      end

      local function lock_is_stale(lock, now)
        if not lock then return true end
        local age = now - lock.started
        if lock.busy == "render" then return age > RENDER_LOCK_MAX_AGE end
        return age >= 60
      end

      local function load_bridge()
        -- The bridge derives its dir from REAPER_AGENT_BRIDGE_DIR when set
        -- (dofile via __startup.lua would otherwise report the launcher's
        -- path). This mirrors setup/install.py's managed block.
        local live_file = live_dir .. "/reaper_agent_bridge.lua"
        local f = io.open(live_file, "r")
        if f then
          f:close()
          REAPER_AGENT_BRIDGE_DIR = live_dir
          local ok, err = pcall(dofile, live_file)
          if not ok then
            reaper.ShowConsoleMsg("[agent-bridge] startup load failed: " .. tostring(err) .. "\n")
          end
          return
        end
        local vf = io.open(vendored_file, "r")
        if vf then
          vf:close()
          REAPER_AGENT_BRIDGE_DIR = reaper.GetResourcePath() .. "/Scripts/reaper-daemon"
          local ok, err = pcall(dofile, vendored_file)
          if not ok then
            reaper.ShowConsoleMsg("[agent-bridge] startup load failed: " .. tostring(err) .. "\n")
          end
        else
          reaper.ShowConsoleMsg("[agent-bridge] startup: bridge NOT found (live checkout or vendored copy)\n")
        end
      end

      load_bridge()

      local watchdog_interval = 10
      local watchdog_last = reaper.time_precise()
      local function watchdog()
        local now = reaper.time_precise()
        if now - watchdog_last >= watchdog_interval then
          watchdog_last = now
          if lock_is_stale(read_lock(), os.time()) then
            reaper.ShowConsoleMsg("[agent-bridge] watchdog: bridge stopped, restarting...\n")
            load_bridge()
          end
        end
        reaper.defer(watchdog)
      end
      reaper.defer(watchdog)
    end
  '';

in
{
  programs.reaper = {
    resourceFiles.files = {
      "Scripts/reaper-mcp/reaper_mcp_server.lua" =
        "${reaper-mcp-lua}/reaper_scripts/reaper_mcp_server.lua";
      "Scripts/reaper-daemon/startup.lua" = daemonStartup;
      "Scripts/reaper-daemon/reaper_agent_bridge.lua" = daemonBridgeFile "reaper_agent_bridge.lua";
      "Scripts/reaper-daemon/json.lua" = daemonBridgeFile "json.lua";
    };

    lineFiles.files."Scripts/__startup.lua" = [
      ''pcall(dofile, reaper.GetResourcePath() .. "/Scripts/reaper-mcp/reaper_mcp_server.lua")''
      ''pcall(dofile, reaper.GetResourcePath() .. "/Scripts/reaper-daemon/startup.lua")''
    ];

    actions.scripts = [
      {
        path = "reaper-mcp/reaper_mcp_server.lua";
        description = "Custom: reaper-mcp bridge (xDarkzx MCP)";
      }
      {
        path = "reaper-daemon/reaper_agent_bridge.lua";
        description = "Custom: reaper-daemon bridge";
      }
    ];
  };

  home.packages = [ xdarkzx-reaper-mcp ];
}
