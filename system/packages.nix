# Shared packages
# Moved verbatim from configuration.nix.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    wget
    jq
    yq
    git
    bibata-cursors
    gnome-keyring
    libsecret
    nautilus
    proton-pass-cli
    xwayland-satellite
    xwayland-run
    unar
    file-roller
    vulkan-tools
  ];
}
