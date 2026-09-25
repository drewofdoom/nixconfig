{
  pkgs,
  ...
}:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    extraPackages = with pkgs; [
      glow
      eza
      bat
      jq
      poppler-utils
      exiftool
      rich-cli
      mediainfo
      unar
      yq
    ];
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
            mime = "image/*";
            run = "piper -- exiftool \"$1\"";
          }
          {
            mime = "{audio,video}/*";
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
            mime = "text/markdown";
            run = "piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark \"$1\"";
          }
          {
            mime = "application/json";
            run = "piper -- jq --color-output . \"$1\"";
          }
          {
            mime = "application/yaml";
            run = "piper -- yq --color-output . \"$1\"";
          }
          {
            mime = "application/pdf";
            run = "piper -- pdftotext -l 10 -nopgbrk -q -- \"$1\" - | bat -p --color=always -l md";
          }
          {
            mime = "text/csv";
            run = "piper -- rich \"$1\" --max-rows 100";
          }
          {
            url = "*/";
            run = "piper -- eza -TL=2 --color=always --icons=always --group-directories-first --no-quotes \"$1\"";
          }
          {
            mime = "{text}/*";
            run = "piper -- bat -p --color=always \"$1\"";
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
