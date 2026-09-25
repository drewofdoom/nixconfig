# Shared packages
# Moved verbatim from configuration.nix.
{ pkgs, ... }:

let
  # TEMP PIN (2026-09-25): xwayland-satellite 0.8.2 breaks Steam's file-picker
  # dialogs (can't Add Non-Steam Game). Downgrade to 0.8.1 until upstream fixes
  # it. Hashes from nixpkgs @ a5cbcfe954791221bfffe2307f7d1a1bf61a871e.
  # Revert: delete this binding and use plain `xwayland-satellite` below.
  xwayland-satellite-081 = pkgs.xwayland-satellite.overrideAttrs (old: {
    version = "0.8.1";
    src = pkgs.fetchFromGitHub {
      owner = "Supreeeme";
      repo = "xwayland-satellite";
      tag = "v0.8.1";
      hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
    };
    cargoHash = "sha256-16L6gsvze+m7XCJlOA1lsPNELE3D364ef2FTdkh0rVY=";
  });
in

{
  environment.systemPackages = with pkgs; [
    gnome-keyring
    libsecret
    vulkan-tools
    xwayland-run
    xwayland-satellite-081
  ];
}
