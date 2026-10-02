# Hardware + realtime: graphics, audio, polkit, keyring.
# Moved verbatim from configuration.nix.
{ ... }:

{
  # Intel Mesa graphics with 32-bit support (Wine/DXVK needs both).
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Enable Bluetooth
    bluetooth.enable = true;
  };

  services = {
    upower.enable = true;
    power-profiles-daemon.enable = true;
    gnome.gnome-keyring.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  security = {
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.tailscale.ipn.Native" && subject.isInGroup("tailscale")) {
            return polkit.Result.YES;
          }
        });
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.RealtimePolicy" && subject.isInGroup("audio")) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    pam = {
      # Use GnomeKeyring for secrets
      services = {
        greetd.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };

      # Pro-audio realtime privileges for the audio group (drew is a member).
      # Fixes yabridge "low memory locking limit" warning and JACK realtime errors.
      loginLimits = [
        {
          domain = "@audio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@audio";
          item = "rtprio";
          type = "-";
          value = "95";
        }
        {
          domain = "@audio";
          item = "nice";
          type = "-";
          value = "-19";
        }
      ];
    };

    # Realtime
    rtkit.enable = true;
  };

  # Secret Service provider for Noctalia (clipboard, calendar creds).
  programs.seahorse.enable = true;
}
