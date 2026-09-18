# blackstar-only home config (gaming + yabridge-via-Bottles machine).
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    heroic
    protonplus
    protontricks
    gamescope
    mangohud

    # wineloader.sh dependency (reads the runner from Bottles bottle.yml).
    yq
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
}
