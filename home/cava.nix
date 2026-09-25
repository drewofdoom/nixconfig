{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    cavasik
  ];

  programs.cava = {
    enable = true;
    settings = {
      general.live-config = true;
      input.method = "pipewire";
      output = {
        method = "noncurses";
        channels = "stereo";
        reverse = 0;
      };
      color = {
        theme = "noctalia";
      };
      smoothing = {
        monstercat = 1;
        noise_reduction = 64;
      };
    };
  };
}
