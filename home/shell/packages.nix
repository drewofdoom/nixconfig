{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    bat
    btop
    cpx
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
    lua5_4
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
