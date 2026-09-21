# Hardware + realtime: graphics, audio, polkit, keyring.
# Moved verbatim from configuration.nix.
{ pkgs, ... }:

{
  # Intel Mesa graphics with 32-bit support (Wine/DXVK needs both).
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  security.polkit = {
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
  security.rtkit.enable = true;

  # Pro-audio realtime privileges for the audio group (drew is a member).
  # Fixes yabridge "low memory locking limit" warning and JACK realtime errors.
  security.pam.loginLimits = [
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

  # -- Auth + secrets (minimal, no full GNOME) --
  # polkit daemon (`security.polkit`) + agent. Noctalia v5's native agent is
  # the agent now (shell.polkit_agent = true in home/desktop/noctalia.nix); it themes the
  # prompt to match the shell. The previous hyprpolkitagent service was
  # dropped -- two agents can't both own org.freedesktop.PolicyKit1, and the
  # loser logs "already registered". If Noctalia is ever disabled, restore a
  # standalone agent (hyprpolkitagent or polkit_gnome) or auth prompts vanish.

  # Secret Service provider for Noctalia (clipboard, calendar creds).
  # libsecret alone is not enough - you need a provider.
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
