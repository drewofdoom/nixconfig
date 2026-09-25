# Shell + dev tools: fish, starship, editors, direnv.
# Moved verbatim from home-common.nix.
{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./shell/yazi.nix
    ./shell/packages.nix
    ./shell/git.nix
    ./shell/neovim.nix
  ];

  programs.fish = {
    enable = true;
    shellInit = ''
      fish_add_path --global --prepend "$HOME/.local/bin"
    '';
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      alias cat='bat --plain'
      alias ls='eza --color=always'
      alias ll='eza --long --icons=always'
      alias la='eza -a'
      alias laa='eza -a --long --icons=always'
      alias lx='eza --long --icons=always --hyperlink=auto'
      alias grep='ugrep'
      alias egrep='ugrep -E'
      alias fgrep='ugrep -F'
      alias rgrep='ugrep -R'
      alias t='bat --style=plain --paging=never'
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
  };

  programs.atuin = {
    enable = true;
    # 18.21 wrote history "v2" records to the sync server; stable 18.15.2
    # can't read them (unknown history version "v2"). Stay on unstable.
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.atuin;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
      enter_accept = true;
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Maple Mono NF";
      font-size = 11;
      theme = "noctalia";
      mouse-scroll-multiplier = "precision:1,discrete:1.5";
    };
  };

  # Auto-activate flake devShells on directory entry.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
