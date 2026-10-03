# blackstar host-specific restic backup (home-manager user service).
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    restic
    rclone
    restic-browser
  ];

  services.restic.enable = true;
  services.restic.backups."blackstar" = {
    repository = "rclone:gdrive:Backups/blackstar";
    repositoryFile = null;
    passwordFile = "${config.home.homeDirectory}/.config/restic/blackstar-password";
    rcloneOptions = { };
    paths = [
      "${config.home.homeDirectory}/Documents"
      "${config.home.homeDirectory}/Audio/Archive"
      "${config.home.homeDirectory}/Audio/Assets"
      "${config.home.homeDirectory}/Templates"
      "${config.home.homeDirectory}/Pictures/Avatars"
      "${config.home.homeDirectory}/Pictures/Wallpapers"
      "${config.home.homeDirectory}/.config/reaper-flake"
      "${config.home.homeDirectory}/Projects/reaper-tools"
      "${config.home.homeDirectory}/Projects/nixconfig"
      # Hermes Agent: the durable knowledge worth restoring on a new machine --
      # agent identity (SOUL.md) and the accumulated memory/skills/cron. These
      # are plain markdown/toml, safe to read.
      "${config.home.homeDirectory}/.hermes/SOUL.md"
      "${config.home.homeDirectory}/.hermes/memories"
      "${config.home.homeDirectory}/.hermes/skills"
      "${config.home.homeDirectory}/.hermes/cron"
      "${config.home.homeDirectory}/.hermes/profiles"
    ];
    exclude = [
      ".cache"
      "node_modules"
      "*.tmp"
      ".local/share/Steam"
      "Documents/FabFilter"
      "Documents/iZotope"
      "Documents/Surge"
      "Documentts/VST3"
      # Secrets in ~/.hermes -- deliberately NOT backed up. The LLM key in .env
      # (plus HERMES_MANAGED=false and the dashboard/bot credentials) lives
      # only there; it is per-host, unmanaged, 0600, and must not be copied to
      # Google Drive; mcp-tokens/ are live OAuth credentials.
      # Re-provision both by hand on a rebuilt machine.
      ".env"
      "mcp-tokens"
      # Runtime state, not knowledge: regenerable, and large.
      "state.db"
      "sessions"
      "logs"
    ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    initialize = true;
    runCheck = true;
    inhibitsSleep = true;
    createWrapper = true;
  };
}
