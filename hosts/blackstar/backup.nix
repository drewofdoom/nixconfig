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
      "${config.home.homeDirectory}/.config/reaper-flake/FXChains"
      "${config.home.homeDirectory}/.config/reaper-flake/TrackTemplates"
      "${config.home.homeDirectory}/.config/reaper-flake/ProjectTemplates"
      "${config.home.homeDirectory}/.config/reaper-flake/MIDINoteNames"
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
