# Shared packages
# Moved verbatim from configuration.nix.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dmidecode
    gnome-keyring
    libsecret
    s-tui
    stress
    vulkan-tools
    xwayland-run
    xwayland-satellite
  ];
}
