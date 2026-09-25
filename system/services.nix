# Shared services + system packages: printing, flatpak, gvfs.
# Moved verbatim from configuration.nix.
{ pkgs, ... }:

{
  # -- Networked multifunction (Epson, IPP Everywhere / eSCL) --
  # CUPS prints driverless over IPP; epson-escpr covers older ESC/P-R
  # models that don't. sane-airscan is the network scanner backend
  # (stock SANE is USB-only); avahi provides .local discovery.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };

  # System flatpak daemon (nix-flatpak's Home Manager module manages the
  # user-scope packages declared in home/flatpak.nix).
  services.flatpak.enable = true;

  # GVFS daemon (notably gvfsd-metadata): without it, `gio set ... metadata::*`
  # fails with "Setting attribute ... not supported" -- GLib has nowhere to
  # persist file metadata (Nautilus custom icons/attributes live there).
  services.gvfs.enable = true;

  # environment.systemPackages = with pkgs; [
  #   neovim
  #   wget
  #   jq
  #   yq
  #   git
  #   bibata-cursors
  #   gnome-keyring
  #   libsecret
  #   nautilus
  #   proton-pass-cli
  #   xwayland-satellite
  #   xwayland-run
  #   unar
  #   file-roller
  #   vulkan-tools
  # ];
}
