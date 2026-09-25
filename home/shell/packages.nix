{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # NOTE: no nixpkgs opencode -- unstable (1.18.30) crashes resolving
    # any model (TypeError err_* on every prompt). Stable (1.15.10) exists
    # in nixpkgs but is older than upstream. Upstream binary installed via
    # https://opencode.ai/install to ~/.opencode/bin (1.18.31+, autoupdates).
    # See sessionPath in misc.nix.
    bat
    btop
    exiftool
    eza
    fd
    ffmpeg # ffmpeg/ffprobe/ffplay on PATH
    fzf
    gh
    glib.bin # gio (GIO metadata, e.g. Nautilus custom folder attributes)
    glow
    gping
    jq
    mediainfo
    nil
    nix-search-tv
    nixd
    nodejs
    pandoc
    poppler-utils
    proton-pass-cli
    python3
    rich-cli
    ripgrep
    ugrep
    unar
    uv
    wget
    yq
  ];
}
