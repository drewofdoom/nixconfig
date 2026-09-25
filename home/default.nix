# Shared Home Manager config for drew.
# Thin aggregator: per-area modules below + proaudio.
{
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.umbriel.homeModules.default
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./desktop
    ./shell.nix
    ./theme.nix
    ./apps.nix
    ./wine.nix
    ./flatpak.nix
    ./ssh.nix
    ./misc.nix
    ./cava.nix
    ../proaudio
  ];
  home.username = "drew";
  home.homeDirectory = "/home/drew";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  xdg.enable = true;

  # Standard XDG user dirs (Documents, Downloads, Music, ...), created if missing.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
