{
  pkgs,
  ...
}:

{
  # Steam needs its FHS env, udev rules (controllers) and firewall ports --
  # the package alone won't work.
  # extraCompatPackages (-> STEAM_EXTRA_COMPAT_TOOLS_PATHS) is the *only*
  # supported way to get Proton-GE on NixOS. proton-ge-bin deliberately ships
  # a junk `out` output telling you not to add it to an environment; the real
  # tool is its `steamcompattool` output, which the steam module points Steam
  # at via makeSearchPathOutput. Steam then finds the tool through the
  # compatibilitytool.vdf in that output. Do NOT install it into
  # environment.systemPackages / home.packages -- that would only put the
  # breadcrumb text on PATH, not a working tool.
  # ProtonPlus drops its downloads into ~/.local/share/Steam/compatibilitytools.d,
  # which Steam reads too but is unmanaged and can go stale (it is currently
  # empty), so declarative is both more reliable and reproducible.
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    # Gamescope session disabled: the monitor's HDR is poor, and the session
    # auto-enables HDR (via ENABLE_GAMESCOPE_WSI/DXVK_HDR defaults) causing
    # corruption on toggle. Use `gamescope -W 3840 -H 1080 -r 60 -- %command%`
    # as a per-game launch option in Steam instead, which scales 3840x1080 up
    # to the panel's native 5120x1440 without touching HDR or leaving Umbriel.
    gamescopeSession.enable = false;
  };
  programs.gamescope = {
    enable = true;
    # capSysNice = true; # BROKEN https://github.com/NixOS/nixpkgs/issues/351516
  };
  programs.gamemode.enable = true;

  # GameMode config (generates /etc/gamemode.ini).
  # desiredgov=performance is the point of GameMode here: it raises the CPU
  # governor only while a game is running, then restores whatever was active.
  # defaultgov is deliberately left unset so exit restores the *current* state
  # rather than forcing one -- that keeps the Noctalia power toggle (which
  # drives power-profiles-daemon) authoritative when no game is running.
  # softrealtime=off: SCHED_ISO is not in upstream kernels, so it is a no-op.
  # disable_splitlock=1 drops the split-lock mitigation during games (it is a
  # measurable cost on this 5800X and the risk is irrelevant for a desktop).
  programs.gamemode.settings = {
    general = {
      desiredgov = "performance";
      softrealtime = "off";
      renice = 0;
      ioprio = 0;
      inhibit_screensaver = 1;
      disable_splitlock = 1;
    };
  };
}
