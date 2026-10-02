# Shared services + system packages: printing, flatpak, gvfs.
# Moved verbatim from configuration.nix.
{ pkgs, ... }:

{
  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [ epson-escpr ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # System flatpak daemon (nix-flatpak's Home Manager module manages the
    # user-scope packages declared in home/flatpak.nix).
    flatpak.enable = true;

    # Firmware updates via LVFS (fwupdmgr). Topgrade's `firmware` step
    # (firmware.upgrade = true in home/topgrade.nix) drives it.
    fwupd.enable = true;

    # GVFS daemon (notably gvfsd-metadata)
    gvfs.enable = true;
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };
}
