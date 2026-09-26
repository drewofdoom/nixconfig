# shephard host-specific restic backup (home-manager user service).
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    restic
    rclone
    restic-browser
    backrest
  ];

  services.restic.backups."shephard" = {
    # Repo keyed by hostname, not friendly name.
    repository = "rclone:gdrive:backups/shephard";
    repositoryFile = null;
    passwordFile = "${config.home.homeDirectory}/.config/restic/shephard-password";
    # HM rclone backend reads ~/.config/rclone/rclone.conf by default;
    # use rcloneOptions for extra flags (strip leading --).
    rcloneOptions = { };
    paths = [
      "${config.home.homeDirectory}/Documents"
      "${config.home.homeDirectory}/Projects"
      # Add more per-host source dirs here.
    ];
    exclude = [
      ".cache"
      "node_modules"
      "*.tmp"
      ".local/share/Steam"
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
