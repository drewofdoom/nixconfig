{
  ...
}:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Drew DeVore";
      email = "drew@devorcula.com";
    };
    settings.init.defaultBranch = "main";
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
