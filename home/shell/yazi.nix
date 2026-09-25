{
  pkgs,
  ...
}:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      yazi = {
        mgr = {
          show_hidden = false;
        };
      };
      plugin = {
        prepend_preloaders = [
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/{subrip,postscript,illustrator,dvb.ait,vnd.adobe.illustrator,eps}";
            run = "mediainfo";
          }
          {
            url = "*.{ai,eps,ait}";
            run = "mediainfo";
          }
          {
            mime = "{image}/*";
            run = "mediainfo --no-metadata";
          }
          {
            mime = "{video}/*";
            run = "mediainfo --no-preview";
          }
        ];
        prepend_previewers = [
          {
            mime = "application/{,g}zip";
            run = "lsar";
          }
          {
            mime = "application/{tar,bzip*,7z*,xz,rar}";
            run = "lsar";
          }
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/{subrip,postscript,illustrator,dvb.ait,vnd.adobe.illustrator,eps}";
            run = "mediainfo";
          }
          {
            url = "*.{ai,eps,ait}";
            run = "mediainfo";
          }
          {
            url = "*";
            run = "piper -- echo $1";
          }
        ];
        prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
          }
        ];
      };
      tasks = {
        image_alloc = 1073741824;
      };
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];
    };
    plugins = with pkgs.yaziPlugins; {
      git = {
        package = git;
        setup = true;
      };
      piper.package = piper;
      chmod.package = chmod;
      starship = {
        package = starship;
        setup = true;
      };
      lsar.package = lsar;
      mediainfo.package = mediainfo;
    };
  };
}