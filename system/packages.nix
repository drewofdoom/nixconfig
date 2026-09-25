# Shared packages
# Moved verbatim from configuration.nix.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-keyring
    libsecret
    vulkan-tools
    xwayland-run
    xwayland-satellite
  ];
}
