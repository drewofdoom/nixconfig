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
    ./hermes.nix
    ./wine.nix
    ./flatpak.nix
    ./ssh.nix
    ./git.nix
    ./misc.nix
    ./cava.nix
    ./topgrade.nix
    ../proaudio
  ];
  home = {
    username = "drew";
    homeDirectory = "/home/drew";
    stateVersion = "26.05";
  };
  programs.home-manager.enable = true;

  xdg = {
    enable = true;

    # Standard XDG user dirs (Documents, Downloads, Music, ...), created if missing.
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
