{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Apps
    vcv-rack

    # Plugins
    cardinal
    chow-centaur
    chow-kick
    chow-tape-model
    dexed
    dragonfly-reverb
    geonkick
    lsp-plugins
    ob-xf
    odin2
    reevr
    rnnoise
    sg-323
    surge-xt
    vital
    wolf-shaper
    x42-plugins
    zam-plugins
    zlcompressor
    zlequalizer
    zlsplitter
  ];
}
