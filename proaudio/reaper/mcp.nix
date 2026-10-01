# REAPER MCP server, declaratively via reaper-flake mechanisms.
#
# One server: xDarkzx `reaper-mcp` (PyPI 0.8.1, with [analysis] extras).
# The local `reaper-daemon` checkout was removed from this config (2026-09-29):
# it stays on-disk and is kept in sync by topgrade, but is no longer installed
# or wired in as an MCP. See home/topgrade.nix.
#
# REAPER-side loaders are installed WITHOUT hand-editing the resource dir:
# - Lua files land in Scripts/ via `programs.reaper.resourceFiles.files`
#   (whole-file mechanism, same as the flake's own reapack-startup.lua).
# - `programs.reaper.lineFiles.files."Scripts/__startup.lua"` APPENDS our
#   dofile lines alongside the flake's ReaPack/SWS hooks (additive, with
#   previous-generation cleanup). Never edit __startup.lua by hand.
# - The bridge is also registered in `programs.reaper.actions.scripts`
#   so it can be (re)run from REAPER's action list.
#
# The reaper-tools repo (~/Projects/reaper-tools, pulled from the tailnet Gitea)
# needs four symlinks that its consumers hardcode and cannot be configured, so
# they are created by the repo's own idempotent bootstrap.sh rather than authored
# by Nix:
#   ~/.config/reaper-flake/Scripts/MCP Agent -> .../reaper-scripts
#   ~/.config/reaper-flake/FXChains           -> .../fx-chains
#   ~/.config/reaper-flake/TrackTemplates     -> .../mcp-state/track_templates
#   ~/.reaper_mcp                            -> .../mcp-state
# TrackTemplates deliberately resolves into the MCP's own template dir, so
# agent-saved templates show up in REAPER's native template manager. The two
# use different extensions (*.template vs *.RTrackTemplate) and cannot collide.
# The resource-dir links are safe: reaper-flake merges only the files it
# declares and leaves the rest of the dir alone. Run on every home-manager
# activation: recreates a link deleted by hand, and creates dangling links on a
# machine where the repo has not been cloned yet (they resolve on their own once
# it is). Runs after "writeBoundary" so ~/.config/reaper-flake exists.
{
  pkgs,
  lib,
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

  # Pinned per MEMORY.md: xdarkzx-reaper-mcp 0.8.2.
  xdarkzx-reaper-mcp = pkgs.python3Packages.buildPythonApplication rec {
    pname = "xdarkzx-reaper-mcp";
    version = "0.8.2";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/a6/04/2c91716f3b4dfcfb34743786c47ae57b704ccdf7d375fa1b557d6c57073b/xdarkzx_reaper_mcp-0.8.2.tar.gz";
      sha256 = "sha256-JQpjKCmoEKUo0zOYuvrYjwoJimrGstqxb/Q+WjDLlSE=";
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
    rev = "22663456bb5b8fde57c5af6d6f7cdf7c0627710a"; # v0.8.2
    hash = "sha256-ZALRC7ETaCNeMID+6eyjO3cxX8z9kl9VnNksvmXegPs=";
  };

in
{
  programs.reaper = {
    resourceFiles.files = {
      "Scripts/reaper-mcp/reaper_mcp_server.lua" =
        "${reaper-mcp-lua}/reaper_scripts/reaper_mcp_server.lua";
    };

    lineFiles.files."Scripts/__startup.lua" = [
      ''pcall(dofile, reaper.GetResourcePath() .. "/Scripts/reaper-mcp/reaper_mcp_server.lua")''
    ];

    actions.scripts = [
      {
        path = "reaper-mcp/reaper_mcp_server.lua";
        description = "Custom: reaper-mcp bridge (xDarkzx MCP)";
      }
    ];
  };

  home.packages = [ xdarkzx-reaper-mcp ];

  # bootstrap.sh runs `python3 -m py_compile` on the repo's tools/. Home Manager
  # activation scripts run in a minimal environment with NO session PATH, so
  # `python3` resolved to nothing and every python tool reported
  # "command not found" (2026-09-30). This failed the activation even though
  # python3 IS in home.packages -- a profile on PATH is not enough for a script
  # that never sees that PATH. Prepend the explicit interpreter instead.
  home.activation.reaperTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${lib.makeBinPath [ pkgs.python3 ]}:$PATH"
    if [ -x "$HOME/Projects/reaper-tools/bootstrap.sh" ]; then
      "$HOME/Projects/reaper-tools/bootstrap.sh"
    else
      echo "reaper-tools: repo not present — run bootstrap.sh after cloning" >&2
    fi
  '';
}
