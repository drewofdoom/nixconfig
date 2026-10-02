# Desktop: Umbriel compositor, Noctalia shell, greeter, portals.
# Moved verbatim from configuration.nix (+ umbriel package pin).
{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.umbriel.nixosModules.default
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs = {
    # Umbriel Wayland compositor (provides `umbriel` session + portal)
    umbriel = {
      enable = true;
      package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.umbriel;
    };

    # Noctalia v5 shell system-wide + recommended services
    # (NetworkManager, Bluetooth, UPower, power-profiles-daemon)
    noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    # GTK theming base: dconf + portal backend. Actual theme set in home/theme.nix.
    dconf.enable = true;
  };

  # Noctalia Greeter via greetd. Disable any other display manager.
  # Uses flake module: services.displayManager.noctalia-greeter
  services = {
    displayManager = {
      noctalia-greeter = {
        enable = true;
        settings = {
          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 24;
            path = "${pkgs.bibata-cursors}/share/icons";
          };
          keyboard = {
            layout = "us";
          };
          session.default = "Umbriel";
          user.default = "drew";
        };
      };

      # Disable GDM and SDDM (noctalia-greeter handles them)
      gdm.enable = false;
      sddm.enable = false;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    corefonts
    inter # variable (InterVariable.ttf)
    maple-mono.NF # Maple Mono Nerd Font build
  ];
}
