# blackstar host-specific restic backup (home-manager user service).
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    restic
    rclone
    restic-browser
    backrest
  ];

  services.restic.backups."blackstar" = {
    # Repo keyed by hostname, not friendly name.
    repository = "rclone:gdrive:backups/blackstar";
    repositoryFile = null;
    passwordFile = "${config.home.homeDirectory}/.config/restic/blackstar-password";
    rcloneOptions = { };
    paths = [
      "${config.home.homeDirectory}/Documents"
      "${config.home.homeDirectory}/Projects"
      "${config.home.homeDirectory}/Audio/Archive"
      "${config.home.homeDirectory}/Audio/Assets"
      # Workspace is scratch/nodatacow — exclude or include explicitly per need.
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
