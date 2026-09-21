# Shared Nvidia setup for Wayland compositors (Umbriel).
# Open kernel modules + latest driver branch (requires Turing/GTX-16xx or
# newer; blackstar's RTX 3080 qualifies).
{
  config,
  pkgs,
  inputs,
  ...
}:

let
  # legacyPackages doesn't inherit nixpkgs.config.allowUnfree; import with it.
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
    # 610.x from unstable: better Wayland/RTX-30 performance. Both channels
    # are on kernel 7.2.6, so the module ABI matches. Revisit when 26.05
    # catches up, then drop back to config.boot.kernelPackages.nvidiaPackages.
    package = unstablePkgs.linuxPackages_latest.nvidiaPackages.latest;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
