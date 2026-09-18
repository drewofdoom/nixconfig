# blackstar-only home config (gaming + yabridge-via-Bottles machine).
# Also owns the podcast REAPER MCPs — only on blackstar, not shephard/common.
{ config, pkgs, inputs, lib, ... }:

let
  # xdarkzx-reaper-mcp 0.7.1 — declarative replacement for `uv tool install
  # xdarkzx-reaper-mcp[analysis]==0.7.1` to ~/.local/bin. Pinned here; bump via
  # `nix flake update` + `nix-update` or manual hash refresh.
  # Uses sdist hash sha256:bc58406b261278727e7c4e649ea99309d8700f9beeb624cafaa3d9231187c245
  # → SRI sha256-vFhAayYSeHJ+fE5knqmTCdhwD5vutiTK+qPZIxGHwkU=
  xdarkzx-reaper-mcp = pkgs.python3Packages.buildPythonApplication rec {
    pname = "xdarkzx-reaper-mcp";
    version = "0.7.1";
    pyproject = true;

    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/54/23/ea7f5d5fb0b836de6932a91b9f894b04152790055980c1a679b3813a034f/xdarkzx_reaper_mcp-0.7.1.tar.gz";
      hash = "sha256-vFhAayYSeHJ+fE5knqmTCdhwD5vutiTK+qPZIxGHwkU=";
    };

    build-system = with pkgs.python3Packages; [ hatchling ];

    # Analysis deps: numpy + soundfile are in nixpkgs; pyloudnorm is not
    # packaged (would need scipy) and is optional — build succeeds without it.
    # The MCP will still start, just reports "missing pyloudnorm" for loudness LD.
    dependencies = with pkgs.python3Packages; [
      mcp
      numpy
      soundfile
    ];

    # No tests in sdist that need running; skip to avoid extra deps
    doCheck = false;

    meta = {
      description = "MCP server for AI-driven music production in REAPER (xDarkzx)";
      homepage = "https://github.com/xDarkzx/Reaper-MCP";
      mainProgram = "reaper-mcp";
    };
  };
in
{
  home.packages = with pkgs; [
    heroic
    protonplus
    protontricks
    gamescope
    mangohud

    # wineloader.sh dependency (reads the runner from Bottles bottle.yml).
    yq

    # Podcast REAPER MCP — blackstar only
    xdarkzx-reaper-mcp
    # keep uv available for ad-hoc pip work, but MCP itself is now declarative
    uv
  ];

  # Bottles via Flatpak (native Bottles was dropped: broken GL presentation
  # through the steam-run sandbox). The wineloader only reads Bottles' data
  # dirs + runners, so the sandbox doesn't matter -- matches upstream docs.
  services.flatpak.packages = [ "com.usebottles.bottles" ];

  # yabridge-bottles-wineloader, pinned to a commit (upstream is an
  # unversioned script). Refresh: bump `rev` below + new hash from
  # `nix-prefetch-url <raw-url> | nix hash convert --to sri`.
  home.file.".local/bin/wineloader.sh" = {
    source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/microfortnight/yabridge-bottles-wineloader/fa162125a51eb4a08f0100f972782b61b6efbb88/wineloader.sh";
      hash = "sha256-STnZ/tHs/+PgNa1OIbMIb6TPqix1emkMJKOXH/2IkGw=";
    };
    executable = true;
  };

  # WINELOADER must be visible inside Reaper's (GUI) environment, not just
  # shells -- hence both sessionVariables and environment.d. After switching,
  # verify with:
  #   tr '\0' '\n' < /proc/$(pgrep -f '/reaper$' | head -1)/environ | grep -E '^(WINELOADER|PATH)='
  # and confirm `wine`/`yq` resolve there. Reaper must be (re)started after
  # login for the variables to be present.
  home.sessionVariables.WINELOADER = "${config.home.homeDirectory}/.local/bin/wineloader.sh";
  xdg.configFile."environment.d/wineloader.conf".text = ''
    WINELOADER=${config.home.homeDirectory}/.local/bin/wineloader.sh
  '';

  # -- REAPER Daemon bridge (blackstar only) --
  # Upstream has no flake.nix; track it as flake input `reaper-daemon`
  # (github:wretcher207/reaper-daemon, flake = false) and sync the writable
  # clone at ~/Projects/reaper-daemon on every `nh os switch`. The bridge
  # MUST stay writable (inbox/outbox/processing/logs are written at runtime)
  # so we can't just symlink the lua from the nix store (its DEFAULT_BRIDGE_ROOT
  # is parent_dir(SCRIPT_DIR) and would poll the read-only store). Instead,
  # activation rsyncs the input's tracked files into the clone, preserving
  # runtime dirs + .git.
  home.activation.syncReaperDaemon = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    REPO="$HOME/Projects/reaper-daemon"
    SRC="${inputs.reaper-daemon}"
    if [ -e "$SRC/bridge/reaper_agent_bridge.lua" ]; then
      if [ -d "$REPO/.git" ]; then
        # Update existing clone: rsync tracked files, keep runtime state + git + bridge_config (managed separately)
        $VERBOSE_ECHO "syncReaperDaemon: syncing $SRC -> $REPO"
        ${pkgs.rsync}/bin/rsync -a --delete --chmod=Du+w,Fu+w \
          --exclude='.git' --exclude='inbox' --exclude='outbox' \
          --exclude='processing' --exclude='failed' --exclude='archive' \
          --exclude='logs' --exclude='__pycache__' \
          --exclude='bridge/bridge_config.json' \
          "$SRC"/ "$REPO"/
        chmod -R u+w "$REPO"
      elif [ -d "$REPO" ]; then
        $VERBOSE_ECHO "syncReaperDaemon: $REPO exists but not git — merging in"
        ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w \
          --exclude='inbox' --exclude='outbox' \
          --exclude='processing' --exclude='failed' --exclude='archive' \
          --exclude='logs' --exclude='bridge/bridge_config.json' \
          "$SRC"/ "$REPO"/
        chmod -R u+w "$REPO"
      else
        $VERBOSE_ECHO "syncReaperDaemon: fresh checkout $SRC -> $REPO"
        mkdir -p "$(dirname "$REPO")"
        ${pkgs.rsync}/bin/rsync -a --chmod=Du+w,Fu+w --exclude='bridge/bridge_config.json' "$SRC"/ "$REPO"/
        chmod -R u+w "$REPO"
      fi
      # Ensure bridge_config.json exists with audio/project/preference gates open (mirrors `setup/install.py --allow-disk-writes`)
      CONFIG="$REPO/bridge/bridge_config.json"
      if [ ! -f "$CONFIG" ]; then
        $VERBOSE_ECHO "syncReaperDaemon: creating $CONFIG with disk writes allowed"
        mkdir -p "$(dirname "$CONFIG")"
        cat > "$CONFIG" <<'JSON'
{"bridge_root":"/home/drew/Projects/reaper-daemon","poll_interval_seconds":0.25,"adaptive_poll":true,"allow_audio_writes":true,"allow_project_save":true,"allow_preference_writes":true,"allow_risk_level_3":true}
JSON
        chmod u+w "$CONFIG"
      fi
    else
      echo "syncReaperDaemon: input missing bridge/reaper_agent_bridge.lua — skip" >&2
    fi
  '';

  # Ensure REAPER auto-loads the bridge on every launch, declarative version
  # of `python3 setup/install.py`. The managed block is idempotent — matches
  # the upstream installer's BEGIN/END markers but points at the writable clone
  # that activation keeps in sync with the flake input.
  xdg.configFile."REAPER/Scripts/__startup.lua" = {
    text = ''
      -- >>> reaper-agent-bridge (managed) >>>
      -- Auto-load the Reaper Daemon watcher. Managed by nixconfig/hosts/blackstar/home.nix
      -- (syncs ~/Projects/reaper-daemon from flake input `reaper-daemon` on switch).
      do
        local BRIDGE_DIR = "${config.home.homeDirectory}/Projects/reaper-daemon/bridge"
        local bridge_file = BRIDGE_DIR .. "/reaper_agent_bridge.lua"
        local repo_root = BRIDGE_DIR:match("^(.+)[/\\][^/\\]+$") or BRIDGE_DIR
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
          local f = io.open(bridge_file, "r")
          if f then
            f:close()
            REAPER_AGENT_BRIDGE_DIR = BRIDGE_DIR
            local ok, err = pcall(dofile, bridge_file)
            if not ok then
              reaper.ShowConsoleMsg("[agent-bridge] startup load failed: " .. tostring(err) .. "\n")
            end
          else
            reaper.ShowConsoleMsg("[agent-bridge] startup: bridge NOT found at " .. bridge_file .. " -- `nh os switch` to sync flake input?\n")
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
      -- <<< reaper-agent-bridge (managed) <<<
    '';
    # Don't clobber user edits if file exists outside HM (backup instead)
    onChange = ''
      echo "REAPER bridge __startup.lua updated — restart REAPER to load new version"
    '';
  };

  # opencode MCP config — blackstar-only override so `reaper-mcp` resolves via
  # nix profile (home.packages) and daemon points at the writable clone that
  # activation keeps pinned to the flake. Shephard keeps the manual file.
  xdg.configFile."opencode/opencode.jsonc".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    small_model = "openrouter/inclusionai/ling-3.0-flash-vl:free";
    instructions = [ "/home/drew/.config/opencode/REAPER.md" ];
    mcp = {
      reaper = {
        type = "local";
        command = [ "${xdarkzx-reaper-mcp}/bin/reaper-mcp" ];
        enabled = true;
        environment.REAPER_MCP_PROFILE_FILE = "/home/drew/.config/opencode/reaper-podcast.toml";
      };
      "reaper-daemon" = {
        type = "local";
        command = [ "${pkgs.python3}/bin/python3" "${config.home.homeDirectory}/Projects/reaper-daemon/reaper_mcp.py" ];
        enabled = true;
      };
    };
  };
}
