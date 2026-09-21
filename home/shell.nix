# Shell + dev tools: fish, starship, editors, direnv.
# Moved verbatim from home-common.nix.
{
  pkgs,
  inputs,
  ...
}:

let
  # Plezy unstable in order to stay on latest version
  plezy = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.plezy;
in
{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Drew DeVore";
      email = "drew@devorcula.com";
    };
    settings.init.defaultBranch = "main";
  };

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

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Maple Mono NF";
      font-size = 11;
      theme = "noctalia";
    };
  };

  programs.yazi = {
    enable = true;
  };

  # Zed (native, not FHS) + declarative extensions and toolchains.
  # Merges into ~/.config/zed/settings.json, your in-app edits are preserved.
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
    ];
    extraPackages = with pkgs; [
      nil
      nixd
      nixfmt
      ripgrep
      nodejs
      python3
    ];
    userSettings = {
      languages.Nix = {
        language_servers = [ "nil" ];
        formatter = {
          external = {
            command = "nixfmt";
            arguments = [ ];
          };
        };
      };
    };
  };

  # Auto-activate flake devShells on directory entry.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    # NOTE: no nixpkgs opencode -- unstable (1.18.30) crashes resolving
    # any model (TypeError err_* on every prompt). Stable (1.15.10) exists
    # in nixpkgs but is older than upstream. Upstream binary installed via
    # https://opencode.ai/install to ~/.opencode/bin (1.18.31+, autoupdates).
    # See sessionPath in misc.nix.
    gh
    git
    nil
    nixd
    eza
    ugrep
    bat
    ripgrep
    fd
    ffmpeg # ffmpeg/ffprobe/ffplay on PATH
    glib.bin # gio (GIO metadata, e.g. Nautilus custom folder attributes)
    python3
    uv
    nodejs
    btop
    gping
    plezy
  ];
}
