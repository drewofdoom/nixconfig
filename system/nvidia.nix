# Shared Nvidia setup for Wayland compositors (Umbriel).
# Open kernel modules + stable driver branch (requires Turing/GTX-16xx or
# newer; blackstar's RTX 3080 qualifies).
{
  config,
  ...
}:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
