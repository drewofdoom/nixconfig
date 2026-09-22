# Shared Nvidia setup for Wayland compositors (Umbriel).
# Open kernel modules + stable driver branch (requires Turing/GTX-16xx or
# newer; blackstar's RTX 3080 qualifies).
{
  config,
  pkgs,
  inputs,
  ...
}:

let
  # Unstable's 615 branch: stable's 595 doesn't compile against 7.x
  # (gcc-15 strncpy error, 2026-09-22). Both channels carry Zen 7.2.6, so
  # the module ABI check passes. Revisit when stable moves past 595.
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    package = unstablePkgs.linuxPackages_zen.nvidiaPackages.latest;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
