# shephard host-specific restic backup (home-manager user service).
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    restic
    rclone
    restic-browser
  ];

  services.restic.enable = true;
  services.restic.backups."shephard" = {
    # Repo keyed by hostname, not friendly name.
    repository = "rclone:gdrive:Backups/shephard";
    repositoryFile = null;
    passwordFile = "${config.home.homeDirectory}/.config/restic/shephard-password";
    # HM rclone backend reads ~/.config/rclone/rclone.conf by default;
    # use rcloneOptions for extra flags (strip leading --).
    rcloneOptions = { };
    paths = [
      "${config.home.homeDirectory}/Documents"
      # FXChains / TrackTemplates / ProjectTemplates are NOT listed: they are
      # now symlinks into ~/Projects/reaper-tools, which is backed up as a git
      # repo instead. Backing them up from here would follow the link and
      # duplicate the same chains under two paths in the snapshot.
      "${config.home.homeDirectory}/.config/reaper-flake/MIDINoteNames"
      "${config.home.homeDirectory}/Projects/reaper-tools"
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
