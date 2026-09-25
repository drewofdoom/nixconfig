{ ... }:

{
  programs.cava = {
    enable = true;
    settings = {
      input.method = "pipewire";
      output = {
        method = "noncurses";
        channels = "stereo";
        reverse = 1;
      };
      color = {
        theme = "noctalia";
      };
      smoothing = {
        monstercat = 1;
        waves = 1;
        noise_reduction = 77;
      };
    };
  };
}
